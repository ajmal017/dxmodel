class Stock < ActiveRecord::Base
  attr_accessible :ticker, :country, :industry_id, :name, :risk_funda_screen1_score

  has_many :stock_dates
  belongs_to :industry

  validates :ticker, :presence => true, :uniqueness => {:scope => :country}
  validates :name, :presence => true 
  validates :country, :presence => true

end
