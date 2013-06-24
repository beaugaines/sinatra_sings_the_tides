require 'compass'
require 'sinatra'
require 'sinatra/static_assets'
require 'wunderground'
require 'haml'
require 'susy'


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

# access Wundround key
wunderground_key = ENV['WUNDERGROUND_KEY']

# helpers
require './lib/render_partial'

# sinatra vars
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :public_dir, 'public'


configure do
  set :haml, { :format => :html5 }
  set :sass, { :style => :compact, :debug_info => false }
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

before do
  # new wunderground object
  @w_api ||= Wunderground.new("7d43f996448b0cfa")
end


# util fcns

def fetch_tides(state, city)
  tides = @w_api.tide_for(state, city)
  next_highs = tides['tide']['tideSummary'].select { |t| t['data']['type'] == 'High Tide' }[0..2]
end

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

# various
after do
  # redis!
end

not_found do
  'Ugh.  Nothin here. Sorry about that.'
end

# routes
get '/' do
  haml :index
end



post '/tides' do
  upcoming_tides = []
  city = params[:city]
  state = params[:state]
  # fetch tides object
  next_highs = fetch_tides(state, city)
  # calculate last high tide
  last_high = Time.at(next_highs.first['date']['epoch'].to_i - 12*60*60)
    @last_high = timeago(last_high)
    upcoming_tides << @last_high
  end
  next_highs.each do |item|
    time, meridian =  item['date']['pretty'].slice(/\d+:\d+\s\w{2}/).split
    if meridian == 'PM'
      upcoming_tides << "#{time} in the PM"
    else
      upcoming_tides << "#{time} in the AM"
    end
  end
  @last_high = upcoming_tides[0]
  @tide1 = upcoming_tides[1]
  @tide2 = upcoming_tides[2]
  tide_differential = (@tide2 - @tide1).to_i/360
  @last_tide = @tide1 - tide_differential*60*60
  haml :tides, :layout => true
end
