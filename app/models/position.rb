class Position < ActiveRecord::Base
  attr_accessible :stock_id, :enter_signal_date, :quantity, :longshort, :enter_date, :enter_price, :enter_usd_value, :enter_local_value, :exit_signal_date, :exit_date, :exit_price, :exit_usd_value, :exit_local_value, :note

  # ------------- Associations  --------------------
  belongs_to :stock
  has_one :industry, :through => :stock


  # ------------- Validations  --------------------
  # entered_proposed state
  with_options if: -> position { position.enter_signaled? } do |position|
    position.validates :stock_id, presence: true
    position.validates :longshort, presence: true
    position.validates :enter_signal_date, presence: true
  end

  # entered state
  with_options if: -> position { position.entered? } do |position|
    position.validates :enter_date, presence: true
    position.validates :enter_price, presence: true
    position.validates :enter_usd_value, presence: true
    position.validates :enter_local_value, presence: true
    position.validates :quantity, presence: true
  end

  # exit_proposed state
  with_options if: -> position { position.exit_signaled? } do |position|
    position.validates :exit_signal_date, presence: true
    position.validates :exit_date, presence: true
    position.validates :exit_price, presence: true
    position.validates :exit_usd_value, presence: true
    position.validates :exit_local_value, presence: true
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
      transition [:active] => :exit_signaled
    end

    event :exit do
      transition [:exit_signaled] => :exited
    end
  end

  # ------------- Scopes  --------------------
  scope :signaled, where("state = 'enter_signaled' or state = 'exit_signaled'")
  scope :enter_signaled, where("state = 'enter_signaled'")
  scope :exit_signaled, where("state = 'exit_signaled'")

  scope :entered, where("state = 'entered'")
  scope :active, where("state = 'entered'")

  scope :exited, where("state = 'exited'")

  scope :long, where("longshort = 'long'")
  scope :short, where("longshort = 'short'")



  # ------------- Class Methods --------------------
  class << self
  end


  # ------------- Instance Methods -----------------
  def holding_period_high
    stock_date_since_entry_with_highest_high = stock.stock_dates.where("stock_dates.date >= ?", enter_date.to_s(:db)).order('stock_dates.close DESC').limit(1)
    return stock_date_since_entry_with_highest_high.close
  end

  def stop_loss_value
    enter_price * 0.9 if longshort == 'long'
    enter_price * 1.1 if longshort == 'short'
  end

  def stop_loss_triggered? price
    return price < stop_loss_value if longshort == 'long'
    return price > stop_loss_value if longshort == 'short'
  end

end
