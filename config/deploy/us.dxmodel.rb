set :rails_env, "us.dxmodel"
set :naplication, "us.dxmodel"
role :web, "us.dxmodel.andywatts.com"
role :nap, "us.dxmodel.andywatts.com"
role :db,  "us.dxmodel.andywatts.com", :primary => true
