# Capistrano sequence
#  deploy:setup
#    after deploy:setup, db:setup
#
#  deploy
#    update 
#      update_code
#        finalize_update
#          before finalize_update, assets:symlink
#          after finalize_update, bundle:install
#          after finalize_update, db:symlink
#        after update_code, 'assets:precompile'
#      restart

load 'deploy/assets'
require 'bundler/capistrano'

# Database
$:.unshift File.join(File.dirname(__FILE__), './deploy') 

# Main Details
set :application, "dxmodel_staging"
role :web, "dxmodel_staging.andywatts.com"
role :app, "dxmodel_staging.andywatts.com"
role :db,  "dxmodel_staging.andywatts.com", :primary => true

# Server Details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/var/www/dxmodel_staging.andywatts.com"
set :deploy_via, :remote_cache
set :user, "dxmodel"
set :use_sudo, false

set :rails_env, "staging"

# Bundler
set :bundle_without, [:darwin, :development, :test]  # Don't install dev, or test gems

# Github 
set :scm, :git
set :scm_verbose, true
set :scm_username, "andywatts"
set :repository, "git@github.com:andywatts/dxmodel.git"
set :branch, "master"
set :git_enable_submodules, 1
set :git_shallow_clone, 1

# Runtime Dependencies
depend :remote, :gem, "bundler", ">=1.0.7"


# Setup (new server)
task :after_setup, :roles => :app do
end
after 'deploy:setup', 'after_setup'


# Deploy
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
task :after_deploy, :roles => :app do
end
after 'deploy:finalize_update', 'after_deploy'
