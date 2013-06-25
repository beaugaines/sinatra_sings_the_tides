# config/deploy.rb

# Bundler tasks
require 'bundler/capistrano'

set :application, "sinatra_sings_the_tides"
set :repository,  "git@github.com:beaugaines/#{application}.git"
server "97.107.133.190", :web, :app, primary: true

set :scm, :git
set :branch, 'master'

# config for rbenv
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

# do not use sudo
set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

# This is needed to correctly handle sudo password prompt
default_run_options[:pty] = true

set :user, "me"
set :group, 'deployers'
set :runner, user

set :host, "#{user}@97.107.133.190" # We need to be able to SSH to that box as this user.
# role :web, host
role :app, host

# rack config
set :rack_env, :production

# ssh options
set :ssh_options, { :forward_agent => true }

# keep 5 releases
after "deploy", "deploy:cleanup" 

# Where will it be located on a server?
set :deploy_to, "/var/www/#{application}"
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

set :public_children, ["stylesheets","images","javascripts"]
 
namespace :deploy do
 
  task :restart do
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D; fi"
  end
 
  task :start do
    run "cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D"
  end
 
  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
 
end
