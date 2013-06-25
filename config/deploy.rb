set :application, 'SinatraSingsTheTides'
set :deploy_to, '/home/me/apps/sinatra_sings_the_tides'
set :repository, 'git@github.com:beaugaines/sinatra_sings_the_tides.git'

# thin pid
set :unicorn_pid, "#{deploy_to}/shared/log/unicorn.pid"

# ensure rack ENV
set :unicorn_command, "cd #{deploy_to}/current && RACK_ENV=production bundle exec unicorn"

# set up ssh
set :user, 'me'
set :domain, "#{user}@97.107.133.190"
set :revision, 'origin/master'
