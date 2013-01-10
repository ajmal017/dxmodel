class ReportsController < ApplicationController
  
  def exposure
    dates = StockDate.select('distinct date').where("date > ?", 90.days.ago).order('date ASC').collect(&:date)

    dates.each do |date|
      
    end

  end

end
