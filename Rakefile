require 'rubygems'
require 'bundler'
require 'sinatra/asset_pipeline/task.rb'
require './app'
require 'rake'
Bundler.setup

Dir["tasks/*.rake"].sort.each { |ext| load ext }

Sinatra::AssetPipeline::Task.define! App

