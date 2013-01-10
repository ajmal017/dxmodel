class FxRate < ActiveRecord::Base
  attr_accessible :date, :usdsgd, :usdhkd

  validates :date, :presence => true
  validates :usdsgd, :presence => true, :uniqueness => {:scope => :date}
  validates :usdhkd, :presence => true, :uniqueness => {:scope => :date}

end
