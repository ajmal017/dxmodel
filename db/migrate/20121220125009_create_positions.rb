class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :state

      t.integer :stock_id

      t.string :longshort

      t.integer :quantity

      t.date    :enter_signal_date
      t.date    :enter_date
      t.decimal :enter_price, :precision => 8, :scale => 4
      t.decimal :enter_usd_value, :precision => 8, :scale => 4
      t.decimal :enter_local_value, :precision => 8, :scale => 4

      t.date    :exit_signal_date
      t.date    :exit_date
      t.decimal :exit_price, :precision => 8, :scale => 4
      t.decimal :exit_usd_value, :precision => 8, :scale => 4
      t.decimal :exit_local_value, :precision => 8, :scale => 4

      t.string  :note
      t.timestamps
    end
  end
end
