class RemoveOpenPositionFromStockData < ActiveRecord::Migration
  def up
     remove_column :stock_dates, :open_position,           :string
  end

  def down
     add_column :stock_dates, :open_position,           :string
  end
end
