class AddCnyusdToFxRates < ActiveRecord::Migration
  def change
    add_column :fx_rates, :usdcny, :decimal, :precision => 14, :scale => 6
  end
end
