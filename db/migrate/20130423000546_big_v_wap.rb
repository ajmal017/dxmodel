class BigVWap < ActiveRecord::Migration
  def change
     change_column :stock_dates, :vwap, :decimal, :default => 0.0, :precision => 14, :scale => 6
  end
end
