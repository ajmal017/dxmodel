class CreateFxRatesTable < ActiveRecord::Migration
  def change
    create_table :fx_rates do |t|
      t.date :date
      t.decimal :usdsgd, :precision => 14, :scale => 6
      t.decimal :usdhkd, :precision => 14, :scale => 6

      t.timestamps
    end
  end
end
