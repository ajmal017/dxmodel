class EvenBiggerNumbers < ActiveRecord::Migration
  def change
     change_column :stock_dates, :alpha, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :per, :decimal, :default => 0.0, :precision => 20, :scale => 6
     change_column :stock_dates, :per_change, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :pfcf, :decimal, :default => 0.0, :precision => 20, :scale => 6
     change_column :stock_dates, :pfcf_change, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :eps_5yr_growth, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :roe_bf12m, :decimal, :default => 0.0, :precision => 20, :scale => 6
     change_column :stock_dates, :roa_bf12m, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :average_traded_value_30_days, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :close, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :wmavg_10d, :decimal, :default => 0.0, :precision => 20, :scale => 6
     change_column :stock_dates, :smavg_10d, :decimal, :default => 0.0, :precision => 20, :scale => 6

     change_column :stock_dates, :vwap, :decimal, :default => 0.0, :precision => 20, :scale => 6


     change_column :trades, :enter_local_price, :decimal, :precision => 20, :scale => 6
     change_column :trades, :enter_local_value, :decimal, :precision => 20, :scale => 6
     change_column :trades, :enter_usd_value, :decimal, :precision => 20, :scale => 6

     change_column :trades, :exit_local_price, :decimal, :precision => 20, :scale => 6
     change_column :trades, :exit_local_value, :decimal, :precision => 20, :scale => 6
     change_column :trades, :exit_usd_value, :decimal, :precision => 20, :scale => 6
  end
end
