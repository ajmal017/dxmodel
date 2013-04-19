set :rails_env, "production_apac"
set :application, "dxmodel_apac"
role :web, "dxmodel_apac.andywatts.com"
role :app, "dxmodel_apac.andywatts.com"
role :db,  "dxmodel_apac.andywatts.com", :primary => true

