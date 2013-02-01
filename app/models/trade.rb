class Trade < ActiveRecord::Base
  attr_accessible :state, :stock_id, :enter_signal_date, :quantity, :longshort, 
                  :enter_date, :enter_local_price, :enter_usd_value, :enter_local_value, :enter_usd_fx_rate,
                  :exit_signal_date, :exit_date, :exit_local_price, :exit_usd_value, :exit_local_value, :exit_usd_fx_rate, :note

  # ------------- Associations  --------------------
  belongs_to :stock
  has_many :stock_dates, :through => :stock
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

  scope :open_on, lambda{|date| where( "trades.enter_date < ? and (trades.exit_date is null or trades.exit_date > ?)", date, date) }
  scope :closed_on, lambda{|date| where( "trades.exit_date = ?", date) }


  # ------------- Class Methods --------------------
  class << self
  end


  # ------------- Instance Methods -----------------
  def holding_period_high
    stock_date = stock.stock_dates.where("stock_dates.date >= ?", enter_date.to_s)
    stock_date = stock_date.where("stock_dates.date < ?", exit_date.to_s) if exited?
    stock_date = stock_date.order('stock_dates.close DESC')
    return stock_date.first.nil? ? nil : stock_date.first.close
  end


  def holding_period_low
    stock_date = stock.stock_dates.where("stock_dates.date >= ?", enter_date.to_s)
    stock_date = stock_date.where("stock_dates.date < ?", exit_date.to_s) if exited?
    stock_date = stock_date.order('stock_dates.close ASC')
    return stock_date.first.nil? ? nil : stock_date.first.close
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
      return price <= stop_loss_value 

    elsif longshort == 'short' and stop_loss_value
      return price >= stop_loss_value 

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

  # USD value at close
  def usd_value_on_date date
    fx_rate = FxRate.where(date: date).first
    raise "no fx_rate for #{date}" unless fx_rate

    case stock.country
    when 'SP'
      local_value_on_date(date) / fx_rate.usdsgd 
    when 'HK'
      local_value_on_date(date) / fx_rate.usdhkd 
    end
  end

  # Value at close
  def local_value_on_date date
    quantity * stock.price_on_date(date)
  end

  def usd_pnl_on_date date
    exit_value = (exited? ? exit_usd_value : usd_value_on_date(date))  # If exited use exit(vwap) price, else use price at close
    if long?
      exit_value - enter_usd_value

    elsif short?
      enter_usd_value - exit_value 

    end
  end


  def usd_pnl_percentage_on_date date
    value = (usd_pnl_on_date(date) / enter_usd_value) * 100
    value.round(2)
  end

end
