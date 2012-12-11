class CreateStockDates < ActiveRecord::Migration
  def change
    create_table :stock_dates do |t|
      t.integer :stock_id
      t.date :date
      t.float :long_fund_score, :default => 0.0
      t.integer :long_fund_rank_by_industry
      t.integer :long_fund_rank
      t.string :long_signal

      t.float :short_fund_score, :default => 0.0
      t.integer :short_fund_rank_by_industry
      t.integer :short_fund_rank
      t.string :short_signal

      t.string :open_position

      t.timestamps
    end
  end
end
