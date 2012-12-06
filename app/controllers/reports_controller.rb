class ReportsController < ApplicationController
  require 'csv'
  
  def long
    dates = StockScore.select('distinct date').collect(&:date)
    @date1 = dates[0]
    @date2 = dates[1]
    raise "Need data for two dates" unless @date1 and @date2

    @top_fund_stock_scores_for_date1 = top_fund_scores @date1
    @top_fund_stock_scores_for_date2 = top_fund_scores @date2

    @new_top_fund_stocks_on_date1 = (@top_fund_stock_scores_for_date2 - @top_fund_stock_scores_for_date1).collect(&:stock)
    @dropped_top_fund_stocks_on_date1 = (@top_fund_stock_scores_for_date1 - @top_fund_stock_scores_for_date2).collect(&:stock)
  end


private


  # Returns top stock from each industry, followed by second stock, and so on.
  # Returns no more than one third of stocks in each industry
  def top_fund_scores date
    # Get each industry and top one third of it's stocks by rank for a given date
    industries = {}
    Industry.all.each do |industry|
      one_third = (industry.stock_scores.count.to_f / 3.0).ceil
      industries[industry.id] = industry.stock_scores.where('stock_scores.date = ?', date.to_s(:db)).order('stock_scores.fund_rank_by_industry ASC').limit(one_third)
    end

    @tiers = []
    while industries.present? do

      # Populate the tier of stocks
      tier = []
      industries.each_key do |industry|
        # If we have still have stocks in industry, add top one to tier, else, remove industry
        if industries[industry].present?
          tier << industries[industry].shift 
        else
          industries.delete(industry) 
        end
      end

      tier.sort!{|a,b| a <=> b}
      
      @tiers << tier
    end
    @tiers.flatten
  end



end
