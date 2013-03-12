class Trade < ActiveRecord::Base
  attr_accessible :state, :stock_id, :enter_signal_date, :quantity, :longshort, :currency,
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
  scope :enter_signaled, where("state = 'enter_signaled'")
  scope :entered, where("state = 'entered'")
  scope :exit_signaled, where("state = 'exit_signaled'")
  scope :exited, where("state = 'exited'")

  scope :signaled, where("state = 'enter_signaled' or state = 'exit_signaled'")
  scope :active, where("state = 'entered' or state = 'exit_signaled'")

  scope :long, where("longshort = 'long'")
  scope :short, where("longshort = 'short'")

  scope :open_on, lambda{|date| where( "trades.enter_date < ? and (trades.exit_date is null or trades.exit_date > ?)", date, date) }
  scope :closed_on, lambda{|date| where( "trades.exit_date = ?", date) }


  # ------------- Class Methods --------------------
  class << self

    def propose_trade_entries date
      Stock.all.each do |stock|
        stock_date = StockDate.where({stock_id: stock.id, date: date}).first
        next if stock_date.nil?  # skip unless we have rank data for stock on date
        next if stock.trades.entered.first # Skip if we already entered a trade
        
        if stock_date.long_fund_signal == 'ENTER' and stock_date.short_fund_signal == 'ENTER' 
          # Do nothing if signals say enter long and short

        elsif stock_date.long_fund_signal == 'ENTER' and stock_date.long_tech_signal == 'ENTER'
          note = "#{date} Enter long signal."
          note << "\n Fundamentals rank #{stock_date.long_fund_rank}."
          note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} > SMAVG #{stock_date.smavg_10d}"
          trade = Trade.create!(stock_id: stock.id, longshort: 'long', enter_signal_date: date, note: note)

        elsif stock_date.short_fund_signal == 'ENTER' and stock_date.short_tech_signal == 'ENTER'
          note = "#{date} Enter short signal."
          note << "\n Fundamentals rank #{stock_date.short_fund_rank}."
          note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} < SMAVG #{stock_date.smavg_10d}"
          trade = Trade.create!(stock_id: stock.id, longshort: 'short', enter_signal_date: date, note: note)
        end
      end
    end

    def propose_trade_exits date
      Stock.all.each do |stock|
        stock_date = StockDate.where({stock_id: stock.id, date: date}).first
        next if stock_date.nil?  # skip unless we have rank data for stock on date

        # Exit long trade due to fundamentals
        if stock_date.long_fund_signal == 'EXIT' and long_trade = stock.trades.entered.long.try(:first)
          long_trade.exit_signal_date = date
          long_trade.signal_exit!
          long_trade.note_will_change!
          long_trade.note << "\n\n#{date} Exit long signal."
          long_trade.note << "\n Fundamentals rank #{stock_date.long_fund_rank}."
          long_trade.save!

        # Exit long trade due to technicals
        #elsif stock_date.long_tech_signal == 'EXIT' and long_trade = stock.trades.entered.long.try(:first)
          #long_trade.exit_signal_date = date
          #long_trade.signal_exit!
          #long_trade.note_will_change!
          #long_trade.note << "\n\n#{date} Exit long signal."
          #long_trade.note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} < SMAVG #{stock_date.smavg_10d}"
          #long_trade.save!

        # Exit short trade due to fundamentals
        elsif stock_date.short_fund_signal == 'EXIT' and short_trade = stock.trades.entered.short.try(:first)
          short_trade.exit_signal_date = date
          short_trade.signal_exit!
          short_trade.note_will_change!
          short_trade.note << "\n\n#{date} Exit short signal."
          short_trade.note << "\n Fundamentals rank #{stock_date.short_fund_rank}."
          short_trade.save!

        # Exit short trade due to technicals
        #elsif stock_date.short_tech_signal == 'EXIT' and short_trade = stock.trades.entered.short.try(:first)
          #short_trade.exit_signal_date = date
          #short_trade.signal_exit!
          #short_trade.note_will_change!
          #short_trade.note << "\n\n#{date} Exit short signal."
          #short_trade.note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} > SMAVG #{stock_date.smavg_10d}"
          #short_trade.save!

        end
      end
    end

    def propose_exits_for_missing_stocks date
      Trade.entered.each do |trade|
        stock_date = StockDate.where(stock_id: trade.stock_id, date: date).first
        unless stock_date
          trade.exit_signal_date = date
          trade.signal_exit! 
          trade.note_will_change!
          trade.note << "\n\n#{date} Exit signal due to no data in upload."
          trade.save!
        end
      end
    end

    def propose_stop_loss_trades date
      Trade.entered.each do |trade|
        stock_date = StockDate.where(stock_id: trade.stock_id, date: date).first
        if trade.stop_loss_triggered? stock_date.close
          trade.exit_signal_date = date
          trade.signal_exit! 
          trade.note_will_change!
          if trade.longshort == 'long'
            trade.note << "\n\n#{date} Stop loss signal.  Close: #{stock_date.close}.  Holding period high: #{trade.holding_period_high}.  Stop loss value: #{trade.stop_loss_value}."
          elsif trade.longshort == 'short'
            trade.note << "\n\n#{date} Stop loss signal.  Close: #{stock_date.close}.  Holding period low: #{trade.holding_period_low}.  Stop loss value: #{trade.stop_loss_value}."
          end
          trade.save!
        end
      end
    end

    def process_enter_signals date
      Trade.enter_signaled.each do |trade|
        stock_date = StockDate.where('stock_id = ? and date > ?', trade.stock_id, date).order('date ASC').first
        fx_rate = FxRate.where('and date > ?', date).order('date ASC').first.send('USD' + stock.currency)
        enter_local_budget = MAX_PER_ENTRY * trade.fx_rate

        trade.enter_date = date
        trade.enter_fx_rate = fx_rate
        trade.enter_local_price = stock_date.vwap
        trade.quantity = (enter_local_budget / trade.enter_local_price).floor

        trade.enter_local_value = trade.quantity * trade.enter_local_price
        trade.enter_usd_value = trade.enter_local_value * trade.enter_fx_rate
        trade.state = 'entered'
        trade.save!
      end
    end

    def process_exit_signals date
      Trade.exit_signaled.each do |trade|
        stock_date = StockDate.where('stock_id = ? and date > ?', trade.stock_id, date).order('date ASC').first
        fx_rate = FxRate.where('and date > ?', date).order('date ASC').first.send('USD' + stock.currency)

        trade.exit_date = date
        trade.exit_fx_rate = fx_rate
        trade.exit_local_price = stock_date.vwap

        trade.exit_local_value = trade.quantity * trade.exit_local_price
        trade.exit_usd_value = trade.exit_local_value * trade.exit_fx_rate
        trade.state = 'exited'
        trade.save!
      end
    end
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

    case stock.currency
    when 'SGD'
      local_value_on_date(date) / fx_rate.usdsgd 
    when 'HKD'
      local_value_on_date(date) / fx_rate.usdhkd 
    when 'CNY'
      local_value_on_date(date) / fx_rate.usdcny 
    when 'USD'
      local_value_on_date(date)
    end
  end

  # Value at close
  def local_value_on_date date
    quantity * stock.price_on_date(date)
  end

  def usd_pnl_on_date date
    exit_value = (exited_on_or_before?(date) ? exit_usd_value : usd_value_on_date(date))  # If exited use exit(vwap) price, else use price at close
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

  def exited_on_or_before? date
    exit_date and exit_date <= date
  end
end
