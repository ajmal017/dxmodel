class StocksController < ApplicationController

  
  def show
    @stock = Stock.find params[:id]
    @stock_dates = @stock.stock_dates.order("date desc")

  end
end
