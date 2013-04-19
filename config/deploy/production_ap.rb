set :rails_env, "production_ap"
set :application, "dxmodel_ap"
role :web, "dxmodel_ap.andywatts.com"
role :app, "dxmodel_ap.andywatts.com"
role :db,  "dxmodel_ap.andywatts.com", :primary => true

