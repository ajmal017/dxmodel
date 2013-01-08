class AddVwapToStockDates < ActiveRecord::Migration
  def change
    add_column :stock_dates, :vwap, :decimal, :precision => 8, :scale => 6
  end
end
