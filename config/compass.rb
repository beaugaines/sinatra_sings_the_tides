require 'susy'

if defined?(Sinatra)
  # This is the configuration to use when running within sinatra
  project_path = Sinatra::Application.root
  environment = :development
else
  # this is the configuration to use when running within the compass command line tool.
  css_dir = File.join 'public', 'stylesheets'
  relative_assets = true
  environment = :production
end

# This is common configuration
sass_dir = File.join 'views', 'stylesheets'
images_dir = File.join 'public', 'images'
javascripts_dir = File.join 'public', 'javascripts'
http_path = "/"
http_images_path = "/images"
http_stylesheets_path = "/stylesheets"
http_javascripts_path = "/javascripts"

# Determine whether Compass generates relative or absolute paths
relative_assets       = false

# Determines whether line comments should be added to compiled css for easier debugging
line_comments         = false

# CSS output style - :nested, :expanded, :compact, or :compressed
output_style          = :expanded

# Learn more: http://beta.compass-style.org/help/tutorials/configuration-reference/
