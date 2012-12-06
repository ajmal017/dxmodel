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
require 'rvm/capistrano'
require 'bundler/capistrano'

# Database
$:.unshift File.join(File.dirname(__FILE__), './deploy') 
require "capistrano_database" 

# Main Details
set :application, "dxmodel"
role :web, "dxmodel.andywatts.com"
role :app, "dxmodel.andywatts.com"
role :db,  "dxmodel.andywatts.com", :primary => true

# Server Details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/var/www/dxmodel.andywatts.com"
set :deploy_via, :remote_cache
set :user, "dxmodel"
set :use_sudo, true
set :rake, '/usr/local/rvm/gems/ruby-1.9.3-p194@global/bin/rake'

# RVM
set :rvm_ruby_string, 'ruby-1.9.3@dxmodel'
set :rvm_type, :system

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
before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'
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
