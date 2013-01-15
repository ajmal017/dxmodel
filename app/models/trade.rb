class Trade < ActiveRecord::Base
  attr_accessible :state, :stock_id, :enter_signal_date, :quantity, :longshort, 
                  :enter_date, :enter_local_price, :enter_usd_value, :enter_local_value, :enter_usd_fx_rate,
                  :exit_signal_date, :exit_date, :exit_local_price, :exit_usd_value, :exit_local_value, :exit_usd_fx_rate, :note

  # ------------- Associations  --------------------
  belongs_to :stock
  has_one :industry, :through => :stock


  # ------------- Validations  --------------------
  # entered_signaled state
  with_options if: -> trade { trade.enter_signaled? or trade.entered? or trade.exit_signaled? or trade.exited? } do |trade|
    trade.validates :stock_id, presence: true
    trade.validates :longshort, presence: true
    trade.validates :enter_signal_date, presence: true
  end

  # entered state
  with_options if: -> trade { trade.entered? or trade.exit_signaled? or trade.exited? } do |trade|
    trade.validates :quantity, presence: true
    trade.validates :enter_date, presence: true
    trade.validates :enter_local_price, presence: true
    trade.validates :enter_usd_fx_rate, presence: true
    trade.validates :enter_local_value, presence: true
    trade.validates :enter_usd_value, presence: true
  end

  # exit_signaled state
  with_options if: -> trade { trade.exit_signaled? or trade.exited?} do |trade|
    trade.validates :exit_signal_date, presence: true
  end

  # exited state
  with_options if: -> trade { trade.exited? } do |trade|
    trade.validates :exit_date, presence: true
    trade.validates :exit_local_price, presence: true
    trade.validates :exit_usd_fx_rate, presence: true
    trade.validates :exit_local_value, presence: true
    trade.validates :exit_usd_value, presence: true
  end


  # ------------- State Machine  --------------------
  state_machine :state, :initial => :enter_signaled do
    state :enter_signaled
    state :entered
    state :exit_signaled
    state :exited

    event :enter do
      transition [:enter_signaled] => :entered
    end

    event :signal_exit do
      transition [:entered] => :exit_signaled
    end

    event :exit do
      transition [:exit_signaled] => :exited
    end
  end

  # ------------- Scopes  --------------------
  scope :signaled, where("state = 'enter_signaled' or state = 'exit_signaled'")
  scope :enter_signaled, where("state = 'enter_signaled'")
  scope :entered, where("state = 'entered'")
  scope :exit_signaled, where("state = 'exit_signaled'")
  scope :exited, where("state = 'exited'")

  scope :long, where("longshort = 'long'")
  scope :short, where("longshort = 'short'")



  # ------------- Class Methods --------------------
  class << self
  end


  # ------------- Instance Methods -----------------
  def holding_period_high
    stock_date_since_entry_with_highest_high = stock.stock_dates.where("stock_dates.date >= ?", enter_date.to_s(:db)).order('stock_dates.close DESC').first
    return stock_date_since_entry_with_highest_high.nil? ? nil : stock_date_since_entry_with_highest_high.close
  end

  def holding_period_low
    stock_date_since_entry_with_highest_high = stock.stock_dates.where("stock_dates.date >= ?", enter_date.to_s(:db)).order('stock_dates.close ASC').first
    return stock_date_since_entry_with_highest_high.nil? ? nil : stock_date_since_entry_with_highest_high.close
  end

  def stop_loss_value
    if longshort == 'long' and holding_period_high
      holding_period_high * 0.9 

    elsif longshort == 'short' and holding_period_low
      holding_period_low * 1.05 
    else
      nil
    end
  end

  def stop_loss_triggered? price
    if longshort == 'long' and stop_loss_value
      return price < stop_loss_value 

    elsif longshort == 'short' and stop_loss_value
      return price > stop_loss_value 

    else
      return false
    end
  end

  def long?
    longshort == 'long'
  end

  def short?
    longshort == 'short'
  end

  def usd_value_on_date date
    fx_rate = FxRate.where(date: date).first
    raise "no fx_rate for date" unless fx_rate

    case stock.country
    when 'SP'
      local_value_on_date(date) / fx_rate.usdsgd 
    when 'HK'
      local_value_on_date(date) / fx_rate.usdhkd 
    end
  end

  def local_value_on_date date
    stock_date = StockDate.where("stock_id = ? and date < ?", stock_id, date).order('date DESC').first # Get yesterday's close
    quantity * stock_date.close
  end

  def usd_pnl_on_date date
    if exit_date and date > exit_date
      exit_usd_value - enter_usd_value
      
    else
      usd_value_on_date(date) - enter_usd_value
    end
  end

end
