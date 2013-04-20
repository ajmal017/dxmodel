class AddCurrencies < ActiveRecord::Migration
  def change
     add_column :fx_rates, :usdgbp, :decimal, :precision => 14, :scale => 6
     add_column :fx_rates, :usdeur, :decimal, :precision => 14, :scale => 6
  end
end
