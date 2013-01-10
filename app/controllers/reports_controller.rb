class ReportsController < ApplicationController
  
  def exposure
    dates = StockDate.select('distinct date').where("date > ?", 90.days.ago).order('date ASC').collect(&:date)

    dates.each do |date|
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
