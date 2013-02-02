class Stock < ActiveRecord::Base
  attr_accessible :ticker, :country, :industry_id, :name, :risk_funda_screen1_score, :currency

  has_many :stock_dates
  has_many :trades
  belongs_to :industry

  validates :ticker, :presence => true, :uniqueness => {:scope => :country}
  validates :name, :presence => true 
  validates :country, :presence => true
  validates :currency, :presence => true



  def price_on_date date
    stock_date = StockDate.where("stock_id = ? and date <= ?", id, date).order('date DESC').first 
    stock_date.close
  end

  def unit
    currency + '&nbsp;'.html_safe
  end
end
