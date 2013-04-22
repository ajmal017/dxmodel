set :rails_env, "jp.dxmodel"
set :application, "jp.dxmodel"
role :web, "jp.dxmodel.andywatts.com"
role :app, "jp.dxmodel.andywatts.com"
role :db,  "jp.dxmodel.andywatts.com", :primary => true
set :branch, "jp"
