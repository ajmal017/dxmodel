class ReportsController < ApplicationController
  
  def exposure
    dates = FxRate.select('distinct date').where("date > ?", 90.days.ago).order('date ASC').collect(&:date)
    longs = []
    shorts = []

    dates.each do |date|
      trades = Trade.where("enter_date < ? and (exit_date is null or exit_date > ?)", date.to_s(:db), date.to_s(:db))

      trades.each do |trade|
        longs << trade.usd_value_on_date(date) if trade.long?
        shorts << trade.usd_value_on_date(date) if trade.short?
      end
    end

    render :text => 'todo'
  end

  def aum
    render :text => 'todo'
  end

  def pl
    render :text => 'todo'
  end
end
