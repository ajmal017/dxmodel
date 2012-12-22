class PositionsController < ApplicationController
  
  # Collections

  def signaled
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] ? Date.strptime(params[:date], "%Y-%m-%d") : dates[0]

    @enter_signals = Position.enter_signaled.where(enter_signal_date: @date)
    @exit_signals = Position.exit_signaled.where(exit_signal_date: @date)
  end

  def active
    @active_positions = Position.active
  end

  def exited
    @exited_positions = Position.exited
  end

  def show
    @position = Position.find params[:id]
  end


  # Enter position (Move from enter_proposed to entered)
  def enter
    @position = Position.find params[:id] 

    if request.get?
      flash[:error] = 'To enter a position, it should have state enter_proposed' and redirect_to :back unless @position.enter_signaled?

    elsif request.put?
      Position.transaction do
        @position.attributes = params[:position]
        @position.state = 'entered'

        if @position.save
          flash[:success] = "Successfully entered position."  
          redirect_to signaled_positions_path
        else
          render :enter
        end  
      end
    end
  end



  # Exit position (Move from exit_proposed to exited)
  def enter
    @position = Position.find params[:id] 

    if request.get?
      flash[:error] = 'To enter a position, it should have state enter_proposed' and redirect_to :back unless @position.enter_signaled?

    elsif request.put?
      Position.transaction do
        @position.attributes = params[:position]
        @position.state = 'entered'

        if @position.save
          flash[:success] = "Successfully entered position."  
          redirect_to signaled_positions_path
        else
          render :enter
        end  
      end
    end
  end


end
