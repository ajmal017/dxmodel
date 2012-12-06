class StockScore < ActiveRecord::Base
  attr_accessible :date, :risk_funda_screen1_rank_by_industry, :stock_id

  belongs_to :stock
  has_one :industry, :through => :stock

  validates :stock_id, :presence => true, :uniqueness => {:scope => :date}
end
