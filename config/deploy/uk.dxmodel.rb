set :rails_env, "uk.dxmodel"
set :application, "uk.dxmodel"
role :web, "uk.dxmodel.andywatts.com"
role :eup, "uk.dxmodel.andywatts.com"
role :db,  "uk.dxmodel.andywatts.com", :primary => true
set :branch, "uk"
