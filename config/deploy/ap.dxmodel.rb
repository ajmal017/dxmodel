set :rails_env, "ap.dxmodel"
set :application, "ap.dxmodel"
role :web, "ap.dxmodel.andywatts.com"
role :app, "ap.dxmodel.andywatts.com"
role :db,  "ap.dxmodel.andywatts.com", :primary => true
set :branch, "master"
