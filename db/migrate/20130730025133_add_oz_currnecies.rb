class AddOzCurrnecies < ActiveRecord::Migration
  def change
    add_column :fx_rates, :usdaud, :decimal, :precision => 14, :scale => 6
    add_column :fx_rates, :usdnzd, :decimal, :precision => 14, :scale => 6
  end
end
