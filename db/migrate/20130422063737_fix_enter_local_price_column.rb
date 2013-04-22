class FixEnterLocalPriceColumn < ActiveRecord::Migration
  def change
     change_column :trades, :enter_local_price, :decimal, :precision => 14, :scale => 6
  end
end
