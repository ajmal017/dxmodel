class IndexDatesController < ApplicationController
  
  def index
    @index_dates = IndexDate.order('index_dates.index ASC, index_dates.date DESC')
  end

end
