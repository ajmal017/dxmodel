class UploadsController < ApplicationController
  require 'csv'
  
  def new
  end


  def create
    if params[:file].nil?
      flash[:error] = 'No file specified' and 
      redirect_to new_upload_path 
    else

      Stock.transaction do
        filename = params[:file].original_filename

        # Get date and long or short
        filename =~ /(\d+)(L|S).csv/
        longshort = 'long' if $2.upcase == 'L'
        longshort = 'short' if $2.upcase == 'S'
        date = Date.strptime($1, "%Y%m%d")
        if longshort.nil? or date.nil?
          flash[:error] = "Failed to parse filename.  Does it follow this convention  20121205L.csv or 20121205S.csv?"
          redirect_to new_upload_path
        end

        rows = CSV.parse(params[:file].read)
        rows.delete_at(0) # Remove headings

        create_industries rows     
        create_stocks rows     

        create_stock_dates rows, date

        import_stock_fund_scores rows, date, longshort

        calc_fund_ranks_by_industry longshort, date 
        calc_fund_ranks longshort, date 
        calc_signals longshort, date
        calc_open_positions longshort, date

        flash[:success] = "Upload successful"
        redirect_to reports_path
      end
    end
  end

private

  def create_industries rows
    rows.each_with_index do |row, index|
      industry = Industry.new
      industry.name = row[2]
      industry.save! if industry.valid?
    end
  end  

  def create_stocks rows
    rows.each_with_index do |row, index|
      ticker, country, name, industry_name = data_from_row row
      stock = Stock.where(ticker: ticker, country: country).first
      if stock.nil?
        industry = Industry.where(name: industry_name).first
        stock = Stock.new(ticker: ticker, country: country, industry_id: industry.id, name: name) 
        stock.save! 
      end
    end
  end

  def create_stock_dates rows, date
    rows.each_with_index do |row, index|
      ticker, country, name = data_from_row row
      stock = Stock.where(ticker: ticker, country: country).first
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      stock_date = StockDate.new(date: date, stock_id: stock.id) if stock_date.nil?
      stock_date.save!
    end
  end

  def import_stock_fund_scores rows, date, longshort
    rows.each_with_index do |row, index|
      ticker, country, name = data_from_row row
      stock = Stock.where(ticker: ticker, country: country).first

      stock_dates = StockDate.where({stock_id: stock.id, date: date}).first

      stock_dates.long_fund_score = row[3] if longshort == 'long'
      stock_dates.short_fund_score = row[3] if longshort == 'short'

      stock_dates.save! 
    end
  end

  def calc_fund_ranks_by_industry longshort, date
    Industry.all.each do |industry|
      industry.stock_dates.where("stock_dates.date = '#{date.to_s(:db)}'").order("stock_dates.#{longshort}_fund_score DESC").each_with_index do |stock_dates, index|
        stock_dates["#{longshort}_fund_rank_by_industry"] = index + 1
        stock_dates.save!
      end
    end
  end


  def calc_fund_ranks longshort, date
    Rails.logger.info "############"
    Rails.logger.info "Calculating fundamentals ranks."

    # Get each industry and its top one third ranked stocks for a given date
    industries = {}
    Industry.all.each do |industry|
      industries[industry.id] = industry.stock_dates.where('stock_dates.date = ?', date.to_s(:db)).where("stock_dates.#{longshort}_fund_score IS NOT NULL").order("stock_dates.#{longshort}_fund_rank_by_industry ASC")
    end

    @stock_dates = []
    while industries.present? do

      # Populate the tier of stocks
      tier = []
      industries.each_key do |industry|
        # If we have still have stocks in industry, add top one to current tier, else, remove industry
        industries[industry].present? ? tier << industries[industry].shift : industries.delete(industry) 
      end

      tier.sort!{|a,b| b["#{longshort}_fund_score"] <=> a["#{longshort}_fund_score"]}
      @stock_dates << tier
    end

    # Save the rank
    @stock_dates.flatten.each_with_index do |stock_dates, index| 
      stock_dates.update_attribute("#{longshort}_fund_rank".to_sym, index +1) 
    end
  end



  def calc_signals longshort, date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      # skip unless we have rank data for stock on date
      next if stock_date.nil? 

      if longshort == 'long'
        if stock_date.long_fund_rank <= ENTER_RANK_THRESHOLD 
          stock_date.long_signal = 'ENTER'

        elsif stock_date.long_fund_rank > EXIT_RANK_THRESHOLD 
          stock_date.long_signal = 'EXIT'
        end

      elsif longshort == 'short'
        if stock_date.short_fund_rank <= ENTER_RANK_THRESHOLD 
          stock_date.short_signal = 'ENTER'

        elsif stock_date.short_fund_rank > EXIT_RANK_THRESHOLD 
          stock_date.short_signal = 'EXIT'
        end
      end

      stock_date.save!
    end
  end


  def calc_open_positions longshort, date
    Stock.all.each do |stock|
      # Find or new
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      stock_date = StockDate.new(date: date, stock_id: stock.id) if stock_date.nil?

      previous_date = calc_previous_date date
      previous_stock_date = StockDate.where({stock_id: stock.id, date: previous_date}).first 
      if previous_stock_date
        if previous_stock_date.open_position == '' or previous_stock_date.open_position.nil?
          stock_date.open_position = 'LONG' if previous_stock_date.long_signal == 'ENTER'
          stock_date.open_position = 'SHORT' if previous_stock_date.short_signal == 'ENTER'

        elsif previous_stock_date.open_position == 'LONG' and previous_stock_date.long_signal == 'EXIT'
          stock_date.open_position = '' 

        elsif previous_stock_date.open_position == 'SHORT' and previous_stock_date.short_signal == 'EXIT'
          stock_date.open_position = '' 

        else 
          stock_date.open_position = previous_stock_date.open_position
        end
        stock_date.save!
      end
    end
  end


  # Return previous date with stock date;  return nil
  def calc_previous_date target_date
    dates = StockDate.select('distinct date').order('date ASC').collect(&:date)
    target_date_index = dates.index{|d|d == target_date}
    if target_date_index and target_date_index > 0
      dates[target_date_index -1] 
    else
      nil
    end
  end

  def data_from_row row
    ticker = row[0].split(/\s+/)[0]
    country = row[0].split(/\s+/)[1]
    name = row[1]
    industry_name = row[2]
    return ticker, country, name, industry_name
  end

end
