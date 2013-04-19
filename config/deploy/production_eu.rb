set :rails_env, "production_eu"
set :euplication, "dxmodel_eu"
role :web, "dxmodel_eu.andywatts.com"
role :eup, "dxmodel_eu.andywatts.com"
role :db,  "dxmodel_eu.andywatts.com", :primary => true
