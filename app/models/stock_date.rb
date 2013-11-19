class StockDate < ActiveRecord::Base

  belongs_to :stock
  has_one :industry, :through => :stock

  validates :stock_id, :presence => true, :uniqueness => {:scope => :date}

# Should validate for the below, but currently the upload controller builds and saves stock_date records in pieces...
  validates :date, :presence => true
  validates :long_fund_score, :presence => true
  validates :long_fund_rank_by_industry, :presence => true
  validates :long_fund_rank, :presence => true
  validates :short_fund_score, :presence => true
  validates :short_fund_rank_by_industry, :presence => true
  validates :short_fund_rank, :presence => true
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
#  validates :close, :presence => true
#  validates :wmavg_10d, :presence => true
#  validates :smavg_10d, :presence => true



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
    self.tech_long_enter = (((RSI and RSI_LONG_ENTER) ? rsi_long_enter : true) and (MA_LONG_ENTER ? ma_long_enter : true))
    self.tech_long_exit =  (((RSI and RSI_LONG_EXIT) ? rsi_long_exit : true) and (MA_LONG_EXIT ? ma_long_exit : true))

    self.tech_short_enter = (((RSI and RSI_SHORT_ENTER) ? rsi_short_enter : true) and (MA_SHORT_ENTER ? ma_short_enter : true))
    self.tech_short_exit =  (((RSI and RSI_SHORT_EXIT) ? rsi_short_exit : true) and (MA_SHORT_EXIT ? ma_short_exit : true))
  end


  def calc_fund_signals
    self.fund_long_enter = true if long_fund_rank.present? and long_fund_rank <= LONG_ENTER_RANK_THRESHOLD 
    self.fund_long_exit = true if long_fund_rank.present? and long_fund_rank > LONG_EXIT_RANK_THRESHOLD 

    self.fund_short_enter = true if short_fund_rank.present? and short_fund_rank <= SHORT_ENTER_RANK_THRESHOLD 
    self.fund_short_exit = true if short_fund_rank.present? and  short_fund_rank > SHORT_EXIT_RANK_THRESHOLD 
  end

end
