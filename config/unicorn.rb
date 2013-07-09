app = 'sinatra_sings_the_tides'
root = "/var/www/#{app}"
working_directory "#{root}/current"
pid "#{root}/current/tmp/pids/unicorn.pid"
stderr_path "#{root}/shared/log/unicorn.log"
stdout_path "#{root}/shared/log/unicorn.log"

listen "#{root}/shared/unicorn.sock"
worker_processes 2
timeout 30

preload_app true

before_fork do |server, worker|
  # Quit the old unicorn process
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  child_pid = server.config[:pid].sub(".pid", ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")
end

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{root}/current/Gemfile"
end

# This seems to fix unicorn not refreshing the Gemfile issue
# http://web.archiveorange.com/archive/v/X5NWS5tycCtKI5DJ23rR
# http://unicorn.bogomips.org/Sandbox.html
Unicorn::HttpServer::START_CTX[0] = "#{root}/shared/bundle/ruby/2.0.0/bin/unicorn"

