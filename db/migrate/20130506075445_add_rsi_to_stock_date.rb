class AddRsiToStockDate < ActiveRecord::Migration
  def change
    add_column :stock_dates, :rsi, :float
  end
end
