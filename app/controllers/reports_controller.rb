class ReportsController < ApplicationController
  require 'csv'
  
  def index
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] || dates[0]

    @long_entries = []
    @long_exits = []
    @short_entries = []
    @short_exits = []

    StockDate.where(date: @date).each do |stock_date|
      @long_entries << stock_date if stock_date.long_signal == 'ENTER' and not stock_date.open_position.present?

      @long_exits   << stock_date.stock if stock_date.long_signal == 'EXIT' and stock_date.open_position == 'LONG'
      @short_entries << stock_date.stock if stock_date.short_signal == 'ENTER' and not stock_date.open_position.present?
      @short_exits   << stock_date.stock if stock_date.short_signal == 'EXIT' and stock_date.open_position == 'SHORT'
    end

    # Order the long entries by rank
    @long_entries.sort!{|a, b| a.long_fund_rank <=> b.long_fund_rank}
    @long_entries = @long_entries.collect(&:stock)

  end


private


  # Returns top stock from each industry, followed by second stock, and so on.
  # Returns no more than one third of stocks in each industry
  def top_fund_ranked_stocks date, longshort
    # Get each industry and top one third of it's stocks by rank for a given date
    industries = {}
    Industry.all.each do |industry|
      one_third = (industry.stock_dates.count.to_f / 3.0).ceil

      if longshort == 'long' then
        order = 'stock_dates.long_fund_rank_by_industry ASC'
        where = 'stock_dates.long_fund_score IS NOT NULL'

      elsif longshort == 'short' then
        order = 'stock_dates.short_fund_rank_by_industry ASC'
        where = 'stock_dates.short_fund_score IS NOT NULL'
      end

      industries[industry.id] = industry.stock_dates.where('stock_dates.date = ?', date.to_s(:db)).where(where).order(order).limit(one_third)
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
    @tiers.flatten!
  end


end
