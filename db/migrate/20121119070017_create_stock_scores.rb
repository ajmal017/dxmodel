class CreateStockScores < ActiveRecord::Migration
  def change
    create_table :stock_scores do |t|
      t.integer :stock_id
      t.date :date
      t.float :long_fund_score
      t.float :long_fund_rank_by_industry

      t.float :short_fund_score
      t.float :short_fund_rank_by_industry

      t.timestamps
    end
  end
end
