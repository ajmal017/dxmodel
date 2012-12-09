class AddLongRankShortRankToStockScores < ActiveRecord::Migration
  def change
    add_column :stock_scores, :long_fund_rank, :integer
    add_column :stock_scores, :short_fund_rank, :integer
  end
end
