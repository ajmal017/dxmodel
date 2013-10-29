class FxRatesController < ApplicationController

  before_filter :require_user, :only => [:create, :destroy]

  def new
    @fx_rate = FxRate.new
  end

  def create
    @fx_rate = FxRate.new fx_params
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


private
 
  def fx_params
    params.permit!
  end
end
