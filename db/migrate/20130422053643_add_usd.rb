class AddUsd < ActiveRecord::Migration
  def change
     add_column :fx_rates, :usdusd, :decimal, :precision => 14, :scale => 6
  end
end
