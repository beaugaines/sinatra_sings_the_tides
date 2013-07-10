require 'compass'
require 'sinatra'
require 'sinatra/static_assets'
require 'wunderground'
require 'haml'
require 'susy'
require 'unicorn'

# monkey patch Time
class Time
  def meridian
    self.strftime("%p")
  end

  def am?
    self.meridian == 'AM'
  end

  def pm?
    self.meridian == 'PM'
  end
end

state_hash = { "Alaska"=>"AK", "Alabama"=>"AL", "Arkansas"=>"AR", "American Samoa"=>"AS",
 "Arizona"=>"AZ", "California"=>"CA", "Colorado"=>"CO", "Connecticut"=>"CT",
 "District of Columbia"=>"DC", "Delaware"=>"DE", "Florida"=>"FL", "Georgia"=>"GA",
 "Guam"=>"GU", "Hawaii"=>"HI", "Iowa"=>"IA", "Idaho"=>"ID", "Illinois"=>"IL", "Indiana"=>"IN",
 "Kansas"=>"KS", "Kentucky"=>"KY", "Louisiana"=>"LA", "Massachusetts"=>"MA", "Maryland"=>"MD",
 "Maine"=>"ME", "Michigan"=>"MI", "Minnesota"=>"MN", "Missouri"=>"MO", "Mississippi"=>"MS",
 "Montana"=>"MT", "North Carolina"=>"NC", "North Dakota"=>"ND", "Nebraska"=>"NE", "New Hampshire"=>"NH",
 "New Jersey"=>"NJ", "New Mexico"=>"NM", "Nevada"=>"NV", "New York"=>"NY", "Ohio"=>"OH", "Oklahoma"=>"OK",
 "Oregon"=>"OR", "Pennsylvania"=>"PA", "Puerto Rico"=>"PR", "Rhode Island"=>"RI", "South Carolina"=>"SC",
 "South Dakota"=>"SD", "Tennessee"=>"TN", "Texas"=>"TX", "Utah"=>"UT", "Virginia"=>"VA", "Virgin Islands"=>"VI",
 "Vermont"=>"VT", "Washington"=>"WA", "Wisconsin"=>"WI", "West Virginia"=>"WV", "Wyoming"=>"WY" }


# helpers
require './lib/render_partial'

configure do
  set :app_file, __FILE__
  set :root, File.dirname(__FILE__)
  set :public_dir, 'public'
  set :haml, { :format => :html5 }
  set :sass, { :style => :compact, :debug_info => false }
  set :wunderground_key, ENV['WUNDERGROUND_KEY']
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

before do
  # new wunderground object
  @w_api ||= Wunderground.new(:wunderground_key)
end


# util fcns


def timeago(time, options = {})
 start_date = options.delete(:start_date) || Time.new
 date_format = options.delete(:date_format) || :default
 delta_minutes = (start_date.to_i - time.to_i).floor / 60
 if delta_minutes.abs <= (8724*60)       
   distance = distance_of_time_in_words(delta_minutes)       
   if delta_minutes < 0
      return "#{distance} from now"
   else
      return "#{distance} ago"
   end
 else
    return "on #{DateTime.now.to_formatted_s(date_format)}"
 end
end

def distance_of_time_in_words(minutes)
 case
   when minutes < 1
     "less than a minute"
   when minutes < 50
     pluralize(minutes, "minute")
   when minutes < 90
     "about one hour"
   when minutes < 1080
     "#{(minutes / 60).round} hours"
   when minutes < 1440
     "one day"
   when minutes < 2880
     "about one day"
   else
     "#{(minutes / 1440).round} days"
 end
end


# routes
get '/' do
  haml :index
end


def fetch_tides(state, city)
  tides = @w_api.tide_for(state, city)
  next_highs = tides['tide']['tideSummary'].select { |t| t['data']['type'] == 'High Tide' }[0..1]
end

def format_time time
  time.strftime('%l:%M')
end

def format_search_params
  city = params[:city]
  state = params[:state].upcase
  # check format of city and state
  if city.split.length > 1
    city = city.split.join('_')
  end
  if state.length > 2
    state = state_hash[state]
  end
  [city, state]
end

post '/tides' do
  # initialize collection object
  tides_list = []
  # get state and city from params
  city, state = format_search_params
  # fetch tides object
  next_highs = fetch_tides(state, city)
  begin
    # calculate last high tide
    last_high = Time.at(next_highs.first['date']['epoch'].to_i - 12*60*60)
      tides_list << timeago(last_high) 
    next_highs.each do |item|
      # time, meridian =  item['date']['pretty'].slice(/\d+:\d+\s\w{2}/).split
      time = Time.at(item['date']['epoch'].to_i)
      if time.pm?
        formatted_time = "#{format_time(time)} in the PM"
      else
        formatted_time = "#{format_time(time)} in the AM"
      end
      if time.day > Time.now.day
        formatted_time << ' tomorrow'
      end
      tides_list << formatted_time
    end
    @last_high = tides_list[0]
    @tide1 = tides_list[1]
    @tide2 = tides_list[2]
  rescue
    next
  end
  haml :tides, :layout => true
end

after do
  # redis!
end

not_found do
  'Ugh.  Nothin here. Sorry about that.'
end
