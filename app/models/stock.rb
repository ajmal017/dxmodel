class Stock < ActiveRecord::Base
  attr_accessible :ticker, :country, :industry_id, :name, :risk_funda_screen1_score

  has_many :stock_dates
  has_many :positions
  belongs_to :industry

  validates :ticker, :presence => true, :uniqueness => {:scope => :country}
  validates :name, :presence => true 
  validates :country, :presence => true



  def unit
    case country
    when 'SP'
      'S$'
    when 'HK'
      'HK$'
    else
      ''
    end
  end
end
