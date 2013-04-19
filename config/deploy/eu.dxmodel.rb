set :rails_env, "eu.dxmodel"
set :euplication, "eu.dxmodel"
role :web, "eu.dxmodel.andywatts.com"
role :eup, "eu.dxmodel.andywatts.com"
role :db,  "eu.dxmodel.andywatts.com", :primary => true
