class StockDatesController < ApplicationController
  require 'csv'
  
  before_filter :require_user, :only => [:create, :destroy]

  def index
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] ? Date.strptime(params[:date], "%Y-%m-%d") : dates[0]

    @stock_dates = StockDate.where(date: @date)
  end

  
  def new
  end


  def create
    if params[:date]
      date_obj = Date.strptime(params[:date], "%Y-%m-%d")
      filename_date = date_obj.strftime("%Y%m%d")
    end

    if Trade.enter_signaled.present? or Trade.exit_signaled.present?
      flash[:error] = "Enter or exit signals need actioning before uploading"
      redirect_to new_stock_date_path

    elsif not params[:date].present?
      flash[:error] = "Date mising?"
      redirect_to new_stock_date_path

    elsif params[:long].original_filename != (filename_date + 'L.csv') or params[:short].original_filename != (filename_date + 'S.csv')
      flash[:error] = "Expected #{filename_date}L.csv and #{filename_date}S.csv.  Got #{params[:long].original_filename} and #{params[:short].original_filename}"
      redirect_to new_stock_date_path

    else
      date = params[:date]

      StockDate.transaction do
        long = CSV.parse(params[:long].read, {:headers => true})
        short = CSV.parse(params[:short].read, {:headers => true})

        errors = validate_data long, short
        
        if errors.present?
          flash[:error] = errors.join('<br />').html_safe
          render :new

        else
          [long, short].each do |data|
            create_industries data
            create_stocks data
            create_stock_dates data, date
          end

          import_stock_data long, date, 'long'
          import_stock_data short, date, 'short'

          calc_fund_ranks_by_industry date 

          calc_fund_ranks 'long', date 
          calc_fund_ranks 'short', date 

          calc_fund_signals date
          calc_tech_signals date

          Trade.propose_exits_for_missing_stocks date
          Trade.propose_trade_entries date
          Trade.propose_trade_exits date
          Trade.propose_stop_loss_trades date

          flash[:success] = "Upload successful"
          redirect_to signaled_trades_path
        end
      end
    end
  end

private

  def validate_data long, short
    errors = []
    #optional_fields =  ['Alpha:M-6', 'P/E', 'Live PE Chg', 'P/B', 'Live P/BK Chg', 'P/FCF', 'Live P/CF Chg', 'Diluted EPS - 5 Year Average Growth:Y', 'BEst ROE BF12M', 'BEst ROA BF12M', 'Average Traded Value 30days']
    required_fields = ['Closing PX ', 'WMAVG', 'SMAVG', 'VWAP']


    long.each_with_index do |row, index|
      (required_fields + ['Ranking Model: Long Score']).each { |column| errors << "Long: row #{index + 2}: #{column} missing" if ['','N.A.',nil].include?(row[column])  }
    end
    short.each_with_index do |row, index|
      (required_fields + ['Ranking Model: Short Score']).each { |column| errors << "Short: row #{index + 2}: #{column} missing" if ['','N.A.',nil].include?(row[column]) }
    end
    return errors
  end

  def create_industries rows
    rows.each_with_index do |row, index|
      industry = Industry.new
      industry.name = row['GICS Sector']
      industry.save! if industry.valid?
    end
  end  

  def create_stocks rows
    rows.each_with_index do |row, index|
      ticker, country, name, industry_name, currency = data_from_row row
      stock = Stock.where(ticker: ticker, country: country).first
      if stock.nil?
        industry = Industry.where(name: industry_name).first
        stock = Stock.new(ticker: ticker, country: country, industry_id: industry.id, name: name, currency: currency) 
        stock.save! 
      end
    end
  end

  def create_stock_dates rows, date
    rows.each_with_index do |row, index|
      ticker, country, name = data_from_row row
      stock = Stock.where(ticker: ticker, country: country).first
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      stock_date = StockDate.new(stock_id: stock.id, date: date) if stock_date.nil?
      stock_date.save!
    end
  end

  def import_stock_data rows, date, longshort
    rows.each_with_index do |row, index|
      ticker, country, name = data_from_row row
      stock = Stock.where(ticker: ticker, country: country).first

      stock_dates = StockDate.where({stock_id: stock.id, date: date}).first

      stock_dates.long_fund_score = row['Ranking Model: Long Score'] if longshort == 'long'
      stock_dates.short_fund_score = row['Ranking Model: Short Score'] if longshort == 'short'

      stock_dates.alpha =  ['','N.A.',nil].include?(row['Alpha:M-6']) ? nil : row['Alpha:M-6']

      stock_dates.per =  ['','N.A.',nil].include?(row['P/E']) ? nil : row['P/E']
      stock_dates.per_change =  ['','N.A.',nil].include?(row['Live PE Chg']) ? nil : row['Live PE Chg']
     
      stock_dates.pbr =  ['','N.A.',nil].include?(row['P/B']) ? nil : row['P/B']
      stock_dates.pbr_change =  ['','N.A.',nil].include?(row['Live P/BK Chg']) ? nil : row['Live P/BK Chg']
     
      stock_dates.pfcf =  ['','N.A.',nil].include?(row['P/FCF']) ? nil : row['P/FCF']
      stock_dates.pfcf_change =  ['','N.A.',nil].include?(row['Live P/CF Chg']) ? nil : row['Live P/CF Chg']
     
      stock_dates.eps_5yr_growth =  ['','N.A.',nil].include?(row['Diluted EPS - 5 Year Average Growth:Y']) ? nil : row['Diluted EPS - 5 Year Average Growth:Y']

      stock_dates.roe_bf12m =  ['','N.A.',nil].include?(row['BEst ROE BF12M']) ? nil : row['BEst ROE BF12M']
      stock_dates.roa_bf12m =  ['','N.A.',nil].include?(row['BEst ROA BF12M']) ? nil : row['BEst ROA BF12M']

      stock_dates.average_traded_value_30_days =  ['','N.A.',nil].include?(row['Average Traded Value 30days']) ? nil : row['Average Traded Value 30days']

      stock_dates.close =  ['','N.A.',nil].include?(row['Closing PX ']) ? nil : row['Closing PX ']

      stock_dates.wmavg_10d =  ['','N.A.',nil].include?(row['WMAVG']) ? nil : row['WMAVG']
      stock_dates.smavg_10d =  ['','N.A.',nil].include?(row['SMAVG']) ? nil : row['SMAVG']

      stock_dates.vwap =  ['','N.A.',nil].include?(row['VWAP']) ? nil : row['VWAP']

      stock_dates.save! 
    end
  end

  def calc_fund_ranks_by_industry date
    Industry.all.each do |industry|
      # Long
      industry.stock_dates.where("stock_dates.date = '#{date.to_s}'").order("stock_dates.long_fund_score DESC").each_with_index do |stock_dates, index|
        stock_dates["long_fund_rank_by_industry"] = index + 1
        stock_dates.save!
      end

      # Short
      industry.stock_dates.where("stock_dates.date = '#{date.to_s}'").order("stock_dates.short_fund_score DESC").each_with_index do |stock_dates, index|
        stock_dates["short_fund_rank_by_industry"] = index + 1
        stock_dates.save!
      end
    end
  end

  def calc_fund_ranks longshort, date
    # Get each industry and its top one third ranked stocks for a given date
    industries = {}
    Industry.all.each do |industry|
      industries[industry.id] = industry.stock_dates.where('stock_dates.date = ?', date.to_s).where("stock_dates.#{longshort}_fund_score IS NOT NULL").order("stock_dates.#{longshort}_fund_rank_by_industry ASC")
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

  def calc_fund_signals date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      # skip unless we have rank data for stock on date
      next if stock_date.nil? 

      if stock_date.long_fund_rank <= ENTER_RANK_THRESHOLD 
        stock_date.long_fund_signal = 'ENTER'

      elsif stock_date.long_fund_rank > EXIT_RANK_THRESHOLD 
        stock_date.long_fund_signal = 'EXIT'
      end
      if stock_date.short_fund_rank <= ENTER_RANK_THRESHOLD 
        stock_date.short_fund_signal = 'ENTER'

      elsif stock_date.short_fund_rank > EXIT_RANK_THRESHOLD 
        stock_date.short_fund_signal = 'EXIT'
      end

      expire_report_page_caches
      stock_date.save!
    end
  end

  def calc_tech_signals date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      # skip unless we have rank data for stock on date
      next if stock_date.nil? 
      raise stock_date.inspect if stock_date.wmavg_10d.nil? or stock_date.smavg_10d.nil?
      if stock_date.wmavg_10d > stock_date.smavg_10d
        stock_date.long_tech_signal = 'ENTER'
      elsif stock_date.wmavg_10d < stock_date.smavg_10d
        stock_date.short_tech_signal = 'ENTER'
      end
      stock_date.save!

    end
  end

  def data_from_row row
    ticker = row['Ticker'].split(/\s+/)[0]
    country = row['Ticker'].split(/\s+/)[1]
    name = row['Short Name']
    industry_name = row['GICS Sector']
    currency = row['Currency']
    return ticker, country, name, industry_name, currency
  end

end
