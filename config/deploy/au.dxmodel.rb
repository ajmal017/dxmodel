set :rails_env, "au.dxmodel"
set :application, "au.dxmodel"
role :web, "au.dxmodel.andywatts.com"
role :app, "au.dxmodel.andywatts.com"
role :db,  "au.dxmodel.andywatts.com", :primary => true
set :branch, "au"
