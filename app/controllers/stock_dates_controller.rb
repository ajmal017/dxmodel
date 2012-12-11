class StockDatesController < ApplicationController
  
  def index
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] || dates[0]
    @stock_dates = StockDate.where(date: @date)
  end


private


end
