class StocksController < ApplicationController
  
  def show
    @stock = Stock.find params[:id]
    @stock_dates = @stock.stock_dates.order("date desc")

    begin
      url = "http://www.bloomberg.com/markets/chart/data/1Y/#{@stock.ticker}:#{@stock.country}"
      require 'open-uri'
      json_string = open(url).read
      parsed_json = ActiveSupport::JSON.decode(json_string)

      @stock_close_prices = parsed_json['data_values']
    
    rescue
    end

  end
end
