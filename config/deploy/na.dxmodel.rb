set :rails_env, "na.dxmodel"
set :naplication, "na.dxmodel"
role :web, "na.dxmodel.andywatts.com"
role :nap, "na.dxmodel.andywatts.com"
role :db,  "na.dxmodel.andywatts.com", :primary => true
