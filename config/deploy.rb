require 'rubygems'
require 'bundler/capistrano'

set :user, 'me'
set :application, 'sinatra_sings_the_tides'
set :environment, 'production'
set :deploy_to, "/var/www/#{application}"
set :repository, 'git@github.com:beaugaines/sinatra_sings_the_tides.git'
set :scm, :git
set :use_sudo, false

server '97.107.133.190', :web, :app, :db, primary: true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# config for rbenv
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :unicorn do  
  desc "Zero-downtime restart Unicorn"
  task :restart, except: { no_release: true } do
    if remote_file_exists?(unicorn_pid)
      run "kill -s USR2 `cat #{unicorn_pid}`"
    else
      unicorn.start
    end
  end
  
  desc "Start Unicorn"
  task :start, except: { no_release: true } do
    if remote_file_exists?(unicorn_pid)
      logger.important("Unicorn PIDs found. Check if unicorn is already running.", "Unicorn")
    else
      run "cd #{current_path} && bundle exec unicorn -c #{unicorn_config} -E #{environment} -D"
    end
  end
  
  desc "Gracefully stop Unicorn"
  task :stop, except: { no_release: true } do
    if remote_file_exists?(unicorn_pid)
      run "kill -s QUIT `cat #{unicorn_pid}`"
    else
      logger.important("No PIDs found. Check if unicorn is running.", "Unicorn")
    end
  end
end

after "deploy:restart", "unicorn:restart"


def remote_file_exists?(file_path)
  'true' == capture("if [ -e #{file_path} ]; then echo 'true'; fi").strip
end
