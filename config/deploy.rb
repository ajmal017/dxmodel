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
  after :finishing, 'deploy:cleanup'
end
