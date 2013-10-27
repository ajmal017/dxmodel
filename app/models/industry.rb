class Industry < ActiveRecord::Base

  has_many :stocks
  has_many :stock_dates, :through => :stocks

  validates :name, :presence => true, :uniqueness => true

end
