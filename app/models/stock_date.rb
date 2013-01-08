class StockDate < ActiveRecord::Base
  attr_accessible :date, :risk_funda_screen1_rank_by_industry, :stock_id

  belongs_to :stock
  has_one :industry, :through => :stock

  validates :stock_id, :presence => true, :uniqueness => {:scope => :date}

# Should validate for the below, but currently the upload controller builds and saves stock_date records in pieces...
#  validates :date, :presence => true
#  validates :long_fund_score, :presence => true
#  validates :long_fund_rank_by_industry, :presence => true
#  validates :long_fund_rank, :presence => true
#  validates :short_fund_score, :presence => true
#  validates :short_fund_rank_by_industry, :presence => true
#  validates :short_fund_rank, :presence => true
#  validates :alpha, :presence => true
#  validates :per, :presence => true
#  validates :per_change, :presence => true
#  validates :pbr, :presence => true
#  validates :pbr_change, :presence => true
#  validates :pfcf, :presence => true
#  validates :pfcf_change, :presence => true
#  validates :eps_5yr_growth, :presence => true
#  validates :roe_bf12m, :presence => true
#  validates :roa_bf12m, :presence => true
#  validates :average_traded_value_30_days, :presence => true
#  validates :close, :presence => true
#  validates :wmavg_10d, :presence => true
#  validates :smavg_10d, :presence => true

end
