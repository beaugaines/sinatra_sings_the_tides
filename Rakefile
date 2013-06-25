require 'rubygems'
require 'bundler'
require 'rake'
Bundler.setup

Dir["tasks/*.rake"].sort.each { |ext| load ext }

# deploy with vlad
begin
  require 'vlad'
  Vlad.load :scm => :git, :app => :unicorn
rescue LoadError
  # do nothing
end

