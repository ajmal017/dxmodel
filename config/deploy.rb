require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require "mina_rsync/tasks"



task :ap do
  #set :domain, 'ap.dxmodel.com'
  set :deploy_to, '/var/www/ap.dxmodel.com'
  set :branch, 'ap'
end

task :au do
  set :branch, 'au'
  set :deploy_to, "/var/www/au.dxmodel.com"
end

task :backtest do
  set :branch, 'backtest1'
  set :deploy_to, "/var/www/backtest1.dxmodel.com"
end

task :jp do
  set :branch, 'jp'
  set :deploy_to, "/var/www/jp.dxmodel.com"
end

task :staging do
  set :branch, 'staging'
  set :deploy_to, "/var/www/staging.dxmodel.com"
end

task :uk do
  set :branch, 'uk'
  set :deploy_to, "/var/www/uk.dxmodel.com"
end

task :us do
  set :branch, 'us'
  set :deploy_to, "/var/www/us.dxmodel.com"
end


set :user, 'dxmodel'
set :rsync_options, %w[--recursive --delete --delete-excluded --exclude .git*]
set :shared_dirs, ['log', 'bin', 'tmp', 'vendor/bundle', 'public/system']
set :shared_files, ['config/database.yml']
set :shared_paths, shared_dirs + shared_files

desc "Default env"
task :environment do
end


desc "Setups shared folders and files on a new server."
task :setup => :environment do
  queue  %[echo "-----> Creating shared folders."]
  shared_dirs.each do |shared_dir|
    queue  %[echo "       #{shared_dir}"]
    queue! %[mkdir -p "#{deploy_to}/shared/#{shared_dir}"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/#{shared_dir}"]
  end

  shared_files.each do |shared_file|
    queue  %[echo "-----> Be sure to create shared file '#{shared_file}'."]
  end
end


desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke "rsync:deploy"
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue "touch #{deploy_to}/tmp/restart.txt"
    end
  end
end


