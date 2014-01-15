class StockDate < ActiveRecord::Base

  belongs_to :stock
  has_one :industry, :through => :stock

  validates :stock_id, :presence => true, :uniqueness => {:scope => :date}

  validates :date, :presence => true
  validates :close, :presence => true
  validates :wmavg_10d, :presence => true
  validates :smavg_10d, :presence => true

# Should validate for the below, but currently the upload controller builds and saves stock_date records in pieces...
#  validates :long_fund_score, :presence => true
#  validates :long_fund_rank_by_industry, :presence => true
#  validates :long_fund_rank, :presence => true
#  validates :short_fund_score, :presence => true
#  validates :short_fund_rank_by_industry, :presence => true
#  validates :short_fund_rank, :presence => true
#  validates :alpha, :presence => true
#  validates :per, :presence => true
#  validates :per_change, :presence => true
#  validates :pbr, :presence => true
#  validates :pbr_change, :presence => true
#  validates :pfcf, :presence => true
#  validates :pfcf_change, :presence => true
#  validates :eps_5yr_growth, :presence => true
#  validates :roe_bf12m, :presence => true
#  validates :roa_bf12m, :presence => true
#  validates :average_traded_value_30_days, :presence => true



  # ------------- Instance Methods -----------------
  def calc_ma_signals
    raise self.inspect unless wmavg_10d.present? and smavg_10d.present?
    self.ma_long_enter = (wmavg_10d > smavg_10d) if MA_LONG_ENTER 
    self.ma_long_exit = (wmavg_10d < smavg_10d) if MA_LONG_EXIT

    self.ma_short_enter = (wmavg_10d < smavg_10d) if MA_SHORT_ENTER 
    self.ma_short_exit = (wmavg_10d > smavg_10d) if MA_SHORT_EXIT
  end

  def calc_rsi_signals
    raise self.inspect unless rsi.present? 
    self.rsi_long_enter = rsi < RSI_OVERBOUGHT if RSI_LONG_ENTER 
    self.rsi_short_enter = rsi > RSI_OVERSOLD if RSI_SHORT_ENTER 
  end

  def calc_tech_signals
    self.tech_long_enter = rsi_long_enter if RSI_LONG_ENTER 
    self.tech_long_enter = ma_long_enter if MA_LONG_ENTER
    self.tech_long_enter = (rsi_long_enter and ma_long_enter) if (RSI_LONG_ENTER and MA_LONG_ENTER)

    self.tech_short_enter = rsi_short_enter if RSI_SHORT_ENTER 
    self.tech_short_enter = ma_short_enter if MA_SHORT_ENTER
    self.tech_short_enter = (rsi_short_enter and ma_short_enter) if (RSI_SHORT_ENTER and MA_SHORT_ENTER)


    self.tech_long_exit = rsi_long_exit if RSI_LONG_EXIT
    self.tech_long_exit = ma_long_exit if MA_LONG_EXIT
    self.tech_long_exit = (rsi_long_exit and ma_long_exit) if (RSI_LONG_EXIT and MA_LONG_EXIT)

    self.tech_short_exit = rsi_short_exit if RSI_SHORT_EXIT 
    self.tech_short_exit = ma_short_exit if MA_SHORT_EXIT
    self.tech_short_exit = (rsi_short_exit and ma_short_exit) if (RSI_SHORT_EXIT and MA_SHORT_EXIT)
  end


  def calc_fund_signals
    self.fund_long_enter = true if long_fund_rank.present? and long_fund_rank <= LONG_ENTER_RANK_THRESHOLD 
    self.fund_long_exit = true if long_fund_rank.present? and long_fund_rank > LONG_EXIT_RANK_THRESHOLD 

    self.fund_short_enter = true if short_fund_rank.present? and short_fund_rank <= SHORT_ENTER_RANK_THRESHOLD 
    self.fund_short_exit = true if short_fund_rank.present? and  short_fund_rank > SHORT_EXIT_RANK_THRESHOLD 
  end

end
