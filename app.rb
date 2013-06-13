require 'compass'
require 'sinatra'
require 'wunderground'
require 'geocoder'
require 'haml'
require 'fuzzy_time'

# helpers
require './lib/render_partial'

# sinatra vars
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :public_dir, 'public'


configure do
  # set :haml, { :format => :html5, :escape_html => true }
  set :sass, { :style => :compact, :debug_info => false }
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end


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