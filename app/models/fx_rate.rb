class FxRate < ActiveRecord::Base
  attr_accessible :date, :usdsgd, :usdhkd, :usdcny, :usdjpy, :usdgbp, :usdeur

  validates :date, :presence => true
  validates :usdsgd, :presence => true, :uniqueness => {:scope => :date}, :if => Proc.new {|a| CURRENCIES.include?('SGD') }
  validates :usdhkd, :presence => true, :uniqueness => {:scope => :date}, :if => Proc.new {|a| CURRENCIES.include?('HKD') }
  validates :usdcny, :presence => true, :uniqueness => {:scope => :date}, :if => Proc.new {|a| CURRENCIES.include?('CNY') }
  validates :usdjpy, :presence => true, :uniqueness => {:scope => :date}, :if => Proc.new {|a| CURRENCIES.include?('JPY') }
  validates :usdgbp, :presence => true, :uniqueness => {:scope => :date}, :if => Proc.new {|a| CURRENCIES.include?('GBP') }
  validates :usdeur, :presence => true, :uniqueness => {:scope => :date}, :if => Proc.new {|a| CURRENCIES.include?('EUR') }


  default_scope order('fx_rates.date DESC')


  class << self
    def latest
      FxRate.order('fx_rates.date DESC').first
    end
  end

end
