set :rails_env, "production_na"
set :naplication, "dxmodel_na"
role :web, "dxmodel_na.andywatts.com"
role :nap, "dxmodel_na.andywatts.com"
role :db,  "dxmodel_na.andywatts.com", :primary => true
