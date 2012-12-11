class Industry < ActiveRecord::Base
  attr_accessible :name

  has_many :stocks
  has_many :stock_dates, :through => :stocks

  validates :name, :presence => true, :uniqueness => true

end
