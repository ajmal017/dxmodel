class StocksController < ApplicationController

  before_filter :require_user, :only => [:create, :destroy]

  
  def show
    @stock = Stock.find params[:id]
    @stock_dates = @stock.stock_dates.order("date desc")

  end
end
