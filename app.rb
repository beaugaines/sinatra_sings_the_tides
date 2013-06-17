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

get '/about' do
  haml :about, :layout => :'layouts/application'
end


post '/' do
  puts params.inspect
  upcoming_tides = []
  city = params[:city]
  state = params[:state]
  tides = @w_api.tide_for(state, city)
  next_highs = tides['tide']['tideSummary'].select { |t| t['data']['type'] == 'High Tide' }[0..2]
  next_highs.each_with_index do |item|
    time, meridian =  item['date']['pretty'].slice(/\d+:\d+\s\w{2}/).split
    if meridian == 'PM'
      upcoming_tides << "#{time} in the PM"
    else
      upcoming_tides << "#{time} in the AM"
    end
  end
  @tide1 = upcoming_tides[0]
  @tide2 = upcoming_tides[1]
  @tide3 = upcoming_tides[2]
end
  
  # time, meridian = tides['tide']['tideSummary'][3]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)
  # @high_tide_tomorrow = tides['tide']['tideSummary'][7]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)


# get '/stylesheets/:name.css' do
#   content_type 'text/css', :charset => 'utf-8'
#   sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
# end


