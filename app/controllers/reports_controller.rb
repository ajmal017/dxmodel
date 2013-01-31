class ReportsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
  def exposure
    dates = FxRate.unscoped.select('distinct date').where("date > ?", 90.days.ago).order('date ASC').collect(&:date)
    @long_exposures = []
    @short_exposures = []

    dates.each do |date|
      trades = Trade.open_on(date)

      date_long_exposure = 0
      date_short_exposure = 0

      trades.each do |trade|
        date_long_exposure = date_long_exposure + trade.usd_value_on_date(date) if trade.long?
        date_short_exposure = date_short_exposure + trade.usd_value_on_date(date) if trade.short?
      end

      @long_exposures << [date.to_datetime.to_i * 1000, date_long_exposure.round]
      @short_exposures << [date.to_datetime.to_i * 1000, date_short_exposure.round]
    end
  end

  def aum
    render :text => 'todo'
  end

  def pnl
    dates = FxRate.unscoped.select('distinct date').where("date > ?", 90.days.ago).order('date ASC').collect(&:date)
    @realized = []
    @unrealized = []
    @totals = []
    @percentages = []

    dates.each do |date|
      trades = Trade.where("enter_date < ?", date)

      date_realized = 0
      date_unrealized = 0
      date_total = 0       # value of stocks held on date
      date_enter_total = 0 # price paid for stocks held on date

      trades.each do |trade|
        date_realized = date_realized + trade.usd_pnl_on_date(date) if trade.exited?
        date_unrealized = date_unrealized + trade.usd_pnl_on_date(date) if not trade.exited?
        date_enter_total = date_enter_total + trade.enter_usd_value 
      end
      date_total = date_unrealized + date_realized 

      date_percentage = (date_total.to_f / AUM) * 100.0

      @realized << [date.to_datetime.to_i * 1000, date_realized.to_f.round]
      @unrealized << [date.to_datetime.to_i * 1000, date_unrealized.to_f.round]
      @totals << [date.to_datetime.to_i * 1000, date_total.to_f.round]
      @percentages << [date.to_datetime.to_i * 1000, date_percentage.to_f.round(2)]
    end
  end


  def day
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] ? Date.strptime(params[:date], "%Y-%m-%d") : dates[1]
    @previous_date = dates[ dates.index(@date) - 1 ]
    
    @trades = Trade.closed_on(@date)
    @trades.concat(Trade.open_on(@date))
  end

end
