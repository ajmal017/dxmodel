class AddDataToStockDates < ActiveRecord::Migration
  def change
    add_column  :stock_dates,  :alpha,                         :decimal,  :default  =>  0.0,  :precision  =>  4,   :scale  =>  4
    add_column  :stock_dates,  :per,                           :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :per_change,                    :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :pbr,                           :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :pbr_change,                    :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :pfcf,                          :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :pfcf_change,                   :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :eps_5yr_growth,                :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :roe_bf12m,                     :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :roa_bf12m,                     :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :average_traded_value_30_days,  :decimal,  :default  =>  0.0,  :precision  =>  12,  :scale  =>  4
    add_column  :stock_dates,  :close,                         :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :wmavg_10d,                     :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
    add_column  :stock_dates,  :smavg_10d,                     :decimal,  :default  =>  0.0,  :precision  =>  8,   :scale  =>  4
  end
end
