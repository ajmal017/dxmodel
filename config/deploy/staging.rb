set :stage, :staging

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w{dxmodel@staging.dxmodel.andywatts.com}
role :web, %w{dxmodel@staging.dxmodel.andywatts.com}
role :db,  %w{dxmodel@staging.dxmodel.andywatts.com}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the server list. 
# The second argumentsomething that quacks like a has can be used to set extended properties on the server.
server 'staging.dxmodel.andywatts.com', user: 'dxmodel', roles: %w{web app}, my_property: :my_value


set :application, 'AP Staging DX Model'
set :repo_url, 'git@github.com:andywatts/dxmodel.git'
set :branch, 'staging'
set :deploy_to, "/var/www/staging.dxmodel.andywatts.com"
