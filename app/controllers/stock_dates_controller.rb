class StockDatesController < ApplicationController
  
  def index
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] ? Date.strptime(params[:date], "%Y-%m-%d") : dates[0]

    @stock_dates = StockDate.where(date: @date)
  end


private


end
