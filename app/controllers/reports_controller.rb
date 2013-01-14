class ReportsController < ApplicationController
  
  def exposure
    dates = FxRate.select('distinct date').where("date > ?", 90.days.ago).order('date ASC').collect(&:date)
    @long_exposures = []
    @short_exposures = []

    dates.each do |date|
      trades = Trade.where("enter_date < ? and (exit_date is null or exit_date > ?)", date, date)

      date_long_exposure = 0
      date_short_exposure = 0

      trades.each do |trade|
        date_long_exposure = date_long_exposure + trade.usd_value_on_date(date) if trade.long?
        date_short_exposure = date_short_exposure + trade.usd_value_on_date(date) if trade.short?
      end

      @long_exposures << [date.to_datetime.to_i * 1000, date_long_exposure.to_f]
      @short_exposures << [date.to_datetime.to_i * 1000, date_short_exposure.to_f]
    end
  end

  def aum
    render :text => 'todo'
  end

  def pl
    render :text => 'todo'
  end
end
