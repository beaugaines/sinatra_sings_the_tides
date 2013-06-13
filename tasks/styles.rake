namespace :styles do
  desc 'Run compass stats'
  task :stats => ["stats:default"]

  namespace :stats do

    task :default do
      puts "** Compass stats running here**"
      system "compass stats"
    end

    desc "create log of compass stats"
    task :log do
      t = DateTime.now
      filename = "compass-stats-#{t.strftime("%Y%m%d")}-#{t.strftime("%H%M%S")}.log"
      log_dir = 'log'
      puts '** Logging stats **'
      system 'compass stats' >> "#{log_dir}/#{filename}"
      puts "** Created #{log_dir}/#{filename}"
    end
  end

  desc 'clear styles'
  task :clear => ["compile:clear"]

  desc 'watch and compile'
  task :watch do
    system 'compass watch'
  end

  desc 'list styles'
  task :list do
    system 'ls -lh public/stylesheets'
  end

  desc 'compile new stylesheets'
  task :compile => ["compile:default"]

  namespace :compile do

    task :clear do
      puts '*** clearing styles ***'
      system 'rm -Rfv public/stylesheets/*'
    end

    task :default do
      puts '*** compiling styles ***'
      system 'compass compile'
    end
  end
end