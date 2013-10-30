require 'capistrano/bundler'
set :bundle_roles, :all

set :application, 'DX Model'
set :repo_url, 'git@github.com:andywatts/dxmodel.git'
set :format, :pretty
set :log_level, :info 
set :pty, true
set :keep_releases, 5
# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}


# Roles
role :app, %w{dxmodel@dxmodel.andywatts.com}
role :web, %w{dxmodel@dxmodel.andywatts.com}
role :db,  %w{dxmodel@dxmodel.andywatts.com}

# Servers
server 'dxmodel.andywatts.com', user: 'dxmodel', roles: %w{web app}, my_property: :my_value


namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "mkdir -p #{current_path}/tmp"
      execute "touch #{release_path.join('tmp/restart.txt')}"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'
end
