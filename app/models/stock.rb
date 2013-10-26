class Stock < ActiveRecord::Base

  has_many :stock_dates, :dependent => :destroy
  has_many :trades, :dependent => :destroy
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

  def ticker_country
    ticker + ' ' + country
  end

  def country_ticker
    country + ' ' + ticker
  end
end
