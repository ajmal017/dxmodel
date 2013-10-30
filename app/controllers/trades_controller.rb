class TradesController < ApplicationController
  
  before_filter :require_user, :only => [:create, :destroy]

  def new
    @trade = Trade.new(:state => 'entered')
  end

  def create
    permit_trade_params
    @trade = Trade.new(params[:trade])
    if @trade.save  
      flash[:success] = "Successfully created trade."  
      expire_report_page_caches
      redirect_to entered_trades_path 
    else
      render :new
    end  
  end

  def edit
    @trade = Trade.find params[:id]
  end

  def update
    permit_trade_params
    @trade = Trade.find params[:id]
    if @trade.update_attributes(params[:trade])
      flash[:success] = "Successfully updated trade."  
      redirect_to exited_trades_path 
    else
      render :edit
    end  
  end


  # Collections

  def signaled
    permit_date_param
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] ? Date.strptime(params[:date], "%Y-%m-%d") : dates[0]

    @enter_signals = Trade.where(enter_signal_date: @date)
    @exit_signals = Trade.where(exit_signal_date: @date)
  end

  def entered
    @entered_trades = Trade.entered + Trade.exit_signaled
  end

  def exited
    @exited_trades = Trade.exited
  end

  def show
    @trade = Trade.find params[:id]
  end


  # Members

  # Enter trade (Move from enter_proposed to entered)
  def enter
    permit_trade_params
    @trade = Trade.find params[:id] 

    if request.get?
      flash[:error] = 'To enter a trade, it should have state enter_proposed' and redirect_to :back unless @trade.enter_signaled?

    elsif request.patch?
      Trade.transaction do
        @trade.attributes = params[:trade]
        @trade.state = 'entered'

        if @trade.save
          flash[:success] = "Successfully entered trade."  
          redirect_to signaled_trades_path
        else
          render :enter
        end  
      end
    end
  end



  # Exit trade (Move from exit_proposed to exited)
  def exit
    permit_trade_params
    @trade = Trade.find params[:id] 

    if request.get?
      flash[:error] = 'To exit a trade, it should have state exit_proposed' and redirect_to :back unless @trade.exit_signaled?

    elsif request.patch?
      Trade.transaction do
        @trade.attributes = params[:trade]
        @trade.state = 'exited'

        if @trade.save
          flash[:success] = "Successfully exited trade."  
          redirect_to signaled_trades_path
        else
          render :exit
        end  
      end
    end
  end

private
  
  def permit_trade_params
    params[:trade].permit!
  end

  def permit_date_param
    params.permit(:date)
  end
end
