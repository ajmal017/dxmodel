class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :ticker
      t.string :name
      t.string :country
      t.integer :industry_id

      t.timestamps
    end
  end
end
