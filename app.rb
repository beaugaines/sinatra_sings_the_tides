require 'compass'
require 'sinatra'
require 'sinatra/static_assets'
require 'wunderground'
require 'haml'
require 'susy'
require 'sassy-buttons'


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
    # get request ip - hardcoded for now
    # loc = Geocoder.search(request.ip)
    # @loc = Geocoder.search("64.148.1.83")
    # parse lat and long
    # # lat, long = @loc[0].latitude, @loc[0].longitude
    # # retrieve tides object
    # tides = @w_api.tide_for("#{lat},#{long}")
    # get low tide
    # @low_tide_time = tides['tide']['tideSummary'][1]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)
    # @high_tide_time = tides['tide']['tideSummary'][3]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)
    # @high_tide_tomorrow = tides['tide']['tideSummary'][7]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)
    # @low_tide_time = Time.at(tides['tide']['tideSummary'][0]['date']['epoch'].to_i).fuzzy
    # @low_tide_time = Time.at(tides['tide']['tideSummary'][3]['date']['epoch'].to_i).fuzzy
    # @high_tide_tomorrow = Time.at(tides['tide']['tideSummary'][7]['date']['epoch'].to_i).fuzzy

end

# routes
get '/' do
  haml :index
end

def fetch_tides(state, city)
  tides = @w_api.tide_for(state, city)
  next_highs = tides['tide']['tideSummary'].select { |t| t['data']['type'] == 'High Tide' }[0..2]
end

post '/tides' do
  upcoming_tides = []
  city = params[:city]
  state = params[:state]
  next_highs = fetch_tides(state, city)
  if next_highs.first > Time.now
    last_high = next_highs.first - 12*60*60
    @last_high = last_high.strftime('%I:%M')
    upcoming_tides << @last_high
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
  


