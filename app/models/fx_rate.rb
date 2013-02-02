class FxRate < ActiveRecord::Base
  attr_accessible :date, :usdsgd, :usdhkd, :usdcny

  validates :date, :presence => true
  validates :usdsgd, :presence => true, :uniqueness => {:scope => :date}
  validates :usdhkd, :presence => true, :uniqueness => {:scope => :date}

  default_scope order('fx_rates.date DESC')


  class << self
    def latest
      FxRate.order('fx_rates.date DESC').first
    end
  end

end
