require 'compass'
require 'sinatra'
require 'sinatra/static_assets'
require 'wunderground'
require 'haml'
require 'susy'
require 'pony'
require 'pry'
require 'dotenv'
Dotenv.load if development?

# monkey patch Time and String
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

class String
  def titleize
    no_caps = %w{of etc and by the for on is at to but nor or a via}
    gsub(/\b[a-z]+/) { |w| no_caps.include?(w) ? w : w.capitalize }.
      sub(/^[a-z]/) { |l| l.upcase }.
      sub(/\b[a-z][^\s]*?$/) { |l| l.capitalize }
  end
end
  
# helpers
require './lib/render_partial'

configure do
  set :app_file, __FILE__
  set :root, File.dirname(__FILE__)
  set :public_dir, 'public'
  set :haml, { :format => :html5 }
  set :sass, { :style => :compact, :debug_info => false }
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

configure :development do
  enable :logging, :dump_errors, :raise_errors
end

configure :production do
  Pony.options = {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }
end


STATE_HASH = { "Alaska"=>"AK", "Alabama"=>"AL", "Arkansas"=>"AR", "American Samoa"=>"AS",
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
 
before('/tides') do
  @w_api ||= Wunderground.new(ENV['WUNDERGROUND_KEY'])
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
    "on #{DateTime.now.strftime('%B %e, %Y')}"
 end
end


def distance_of_time_in_words(minutes)
  case
  when minutes < 1
    "less than a minute"
  when minutes == 1
    "one minute"
  when minutes < 50
    "#{minutes} minutes"
  when minutes < 90
    "about one hour"
  when minutes < 1440
    "#{(minutes / 60).round} hours"
  when minutes < 2880
    "about one day"
  else
    "#{(minutes / 1440).round} days"
  end
end

def fuzzy_temperature(temperature)
  case
  when temperature < 30
    'bring your drysuit and some whiskey!'
  when temperature < 40
    'mighty cold'
  when temperature < 50
    'cold'
  when temperature < 60
    'pretty cool'
  when temperature < 70
    'cool-ish'
  when temperature < 80
    'wonderful!'
  when temperature < 90
    'hot!'
  when temperature < 100
    'broiling!'
  when temperature < 110
    'death valley-esque!'
  else
    "you don't wanna know..."
  end
end

def fetch_forecast(state,city)
  weather_object = @w_api.forecast_for(state, city)['forecast']['simpleforecast']['forecastday'][0]
  wund_weather_icon_url = weather_object['icon_url']
  wund_temperature = weather_object['high']['fahrenheit']
  ave_humidity = weather_object['avehumidity']
  max_humidity = weather_object['maxumidity']
  [wund_temperature, ave_humidity]
end

# routes
get '/' do
  haml :index
end

get '/about' do
  expires 86400, :public, :must_revalidate
  haml :about
end

def fetch_tides(state, city)
  tides = @w_api.tide_for(state, city)
  tides['tide']['tideSummary'].select { |t| t['data']['type'] == 'High Tide' }[0..1]
end

def format_time time
  time.strftime('%l:%M')
end

def format_search_params
  city = params[:city]
  state = params[:state].capitalize
  # check format of city and state
  if city.split.length > 1
    city = city.split.join('_')
  end
  if state.length >   2
    state = STATE_HASH[state]
  end
  [city, state]
end

post '/tides' do
  # initialize collection object
  tides_list = []
  @city = params[:city]
  # get state and city from params
  city, state = format_search_params
  # fetch tides object
  tides = @w_api.tide_for(state, city)
  next_highs = tides['tide']['tideSummary'].select { |t| t['data']['type'] == 'High Tide' }[0..1]
  #fetch weather object
  weather = fetch_forecast(state, city)
  # binding.pry
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

post '/send' do
  Pony.mail(:from => "#{params[:email]}", :to => 'beaugaines@gmail.com', :subject =>
    "Message from #{params[:email]} re Sinatra Tides Site", :body => params[:message])
end

after do
  # redis!
end

not_found do
  'Ugh.  Nothin here. Sorry about that.'
end

error do
  'The system experienced an error.  Please try again later'
end
