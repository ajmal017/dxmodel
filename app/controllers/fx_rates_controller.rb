class FxRatesController < ApplicationController
  
  def new
    @fx_rate = FxRate.new
  end

  def create
    @fx_rate = FxRate.new params[:fx_rate]
    if @fx_rate.save  
      flash[:success] = "Successfully saved FX rates."  
      redirect_to fx_rates_path
    else
      render :new
    end  
  end

  def index
    @fx_rates = FxRate.order('date desc').all
  end

end
