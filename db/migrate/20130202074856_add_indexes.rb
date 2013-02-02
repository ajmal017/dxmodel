class AddIndexes < ActiveRecord::Migration
  def change
    add_index :trades, :enter_date
    add_index :trades, :exit_date
    add_index :trades, :stock_id
    add_index :trades, :state

    add_index :stock_dates, :date
    add_index :stock_dates, :stock_id
  end
end
