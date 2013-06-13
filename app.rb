require 'compass'
require 'sinatra'
require 'sinatra/reloader'
require 'wunderground'
require 'geocoder'
require 'haml'
require 'susy'
require 'fuzzy_time'


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

def get_tides
  w_api ||= Wunderground.new("7d43f996448b0cfa")  
end


# before do
#     # new wunderground object
#     @w_api ||= Wunderground.new("7d43f996448b0cfa")
#     # get request ip - hardcoded for now
#     # loc = Geocoder.search(request.ip)
#     @loc = Geocoder.search("64.148.1.83")
#     # parse lat and long
#     lat, long = @loc[0].latitude, @loc[0].longitude
#     # retrieve tides object
#     tides = @w_api.tide_for("#{lat},#{long}")
#     # get low tide
#     # @low_tide_time = tides['tide']['tideSummary'][1]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)
#     # @high_tide_time = tides['tide']['tideSummary'][3]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)
#     # @high_tide_tomorrow = tides['tide']['tideSummary'][7]['date']['pretty'].slice(/\d+:\d+\s\w{2}/)
#     @low_tide_time = Time.at(tides['tide']['tideSummary'][1]['date']['epoch'].to_i).fuzzy
#     @high_tide_time = Time.at(tides['tide']['tideSummary'][3]['date']['epoch'].to_i).fuzzy
#     @high_tide_tomorrow = Time.at(tides['tide']['tideSummary'][7]['date']['epoch'].to_i).fuzzy

# end
  # before {@loc = request.location.city}
  before { @title = 'Hey there!' }

# routes
get '/' do
  haml :index
end

get '/about' do
  haml :about, :layout => :'layouts/application'
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
end


# # errors!

# not_found { haml: '404' }
# error { haml: '500' }

# @@404
# %h1 404!
# %p No page like that here.

# @@500
# %h1 500!
# %p There was an error.  Sorry about that.