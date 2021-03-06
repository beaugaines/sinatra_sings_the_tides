require './app'


# Configuration to use when running within Sinatra
# project_path          = Sinatra::Application.root

# HTTP paths
http_path             = '/'
http_stylesheets_path = '/stylesheets'
http_images_path      = '/images'
http_javascripts_path = '/javascripts'

# File system locations
css_dir               = File.join 'public', 'stylesheets'
sass_dir              = File.join 'views', 'stylesheets'
images_dir            = File.join 'public', 'images'
javascripts_dir       = File.join 'public', 'javascripts'
fonts_dir             = File.join 'public', 'stylesheets', 'fonts'

# Syntax preference
preferred_syntax      = :sass

relative_assets       = false

