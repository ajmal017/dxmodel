class StockDatesController < ApplicationController
  require 'csv'
  
  def index
    dates = StockDate.select('distinct date').order('date DESC').collect(&:date)
    @date = params[:date] ? Date.strptime(params[:date], "%Y-%m-%d") : dates[0]

    @stock_dates = StockDate.where(date: @date)
  end

  
  def new
  end


  def create
    if not params[:long] and not params[:short] 
      flash[:error] = "Failed to parse filename.  Does it follow this convention  20121205L.csv or 20121205S.csv?"
      redirect_to new_upload_path

    elsif not params[:date].present?
      flash[:error] = "Date mising?"
      redirect_to new_upload_path
    else
      date = params[:date]

      Stock.transaction do
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

          propose_exits_for_missing_stocks date
          propose_trade_entries date
          propose_trade_exits date
          propose_stop_loss_trades date

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
      (required_fields).each do |column| 
        errors << "Long: row #{index + 1}: #{column} missing" if ['','N.A.',nil].include?(row[column]) 
      end
    end
    short.each_with_index do |row, index|
      (required_fields).each { |column| errors << "Short: row #{index + 1}: #{column} missing" if ['','N.A.',nil].include?(row[column]) }
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
      industry.stock_dates.where("stock_dates.date = '#{date.to_s}'").order("stock_dates.ong_fund_score DESC").each_with_index do |stock_dates, index|
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

  def propose_trade_entries date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      next if stock_date.nil?  # skip unless we have rank data for stock on date
      next if stock.trades.entered.first # Skip if we already entered a trade
      
      if stock_date.long_fund_signal == 'ENTER' and stock_date.short_fund_signal == 'ENTER' 
        # Do nothing if signals say enter long and short

      elsif stock_date.long_fund_signal == 'ENTER' and stock_date.long_tech_signal == 'ENTER'
        note = "#{date} Enter long signal."
        note << "\n Fundamentals rank #{stock_date.long_fund_rank}."
        note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} > SMAVG #{stock_date.smavg_10d}"
        trade = Trade.create!(stock_id: stock.id, longshort: 'long', enter_signal_date: date, note: note)

      elsif stock_date.short_fund_signal == 'ENTER' and stock_date.short_tech_signal == 'ENTER'
        note = "#{date} Enter short signal."
        note << "\n Fundamentals rank #{stock_date.short_fund_rank}."
        note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} < SMAVG #{stock_date.smavg_10d}"
        trade = Trade.create!(stock_id: stock.id, longshort: 'short', enter_signal_date: date, note: note)
      end
    end
  end

  def propose_trade_exits date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      next if stock_date.nil?  # skip unless we have rank data for stock on date

      # Exit long trade due to fundamentals
      if stock_date.long_fund_signal == 'EXIT' and long_trade = stock.trades.entered.long.try(:first)
        long_trade.exit_signal_date = date
        long_trade.signal_exit!
        long_trade.note_will_change!
        long_trade.note << "\n\n#{date} Exit long signal."
        long_trade.note << "\n Fundamentals rank #{stock_date.long_fund_rank}."
        long_trade.save!

      # Exit long trade due to technicals
      #elsif stock_date.long_tech_signal == 'EXIT' and long_trade = stock.trades.entered.long.try(:first)
        #long_trade.exit_signal_date = date
        #long_trade.signal_exit!
        #long_trade.note_will_change!
        #long_trade.note << "\n\n#{date} Exit long signal."
        #long_trade.note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} < SMAVG #{stock_date.smavg_10d}"
        #long_trade.save!

      # Exit short trade due to fundamentals
      elsif stock_date.short_fund_signal == 'EXIT' and short_trade = stock.trades.entered.short.try(:first)
        short_trade.exit_signal_date = date
        short_trade.signal_exit!
        short_trade.note_will_change!
        short_trade.note << "\n\n#{date} Exit short signal."
        short_trade.note << "\n Fundamentals rank #{stock_date.short_fund_rank}."
        short_trade.save!

      # Exit short trade due to technicals
      #elsif stock_date.short_tech_signal == 'EXIT' and short_trade = stock.trades.entered.short.try(:first)
        #short_trade.exit_signal_date = date
        #short_trade.signal_exit!
        #short_trade.note_will_change!
        #short_trade.note << "\n\n#{date} Exit short signal."
        #short_trade.note << "\n Technical 10 day WMAVG #{stock_date.wmavg_10d} > SMAVG #{stock_date.smavg_10d}"
        #short_trade.save!

      end
    end
  end

  def propose_exits_for_missing_stocks date
    Trade.entered.each do |trade|
      stock_date = StockDate.where(stock_id: trade.stock_id, date: date).first
      unless stock_date
        trade.exit_signal_date = date
        trade.signal_exit! 
        trade.note_will_change!
        trade.note << "\n\n#{date} Exit signal due to no data in upload."
        trade.save!
      end
    end
  end

  def propose_stop_loss_trades date
    Trade.entered.each do |trade|
      stock_date = StockDate.where(stock_id: trade.stock_id, date: date).first
      if trade.stop_loss_triggered? stock_date.close
        trade.exit_signal_date = date
        trade.signal_exit! 
        trade.note_will_change!
        if trade.longshort == 'long'
          trade.note << "\n\n#{date} Stop loss signal.  Close: #{stock_date.close}.  Holding period high: #{trade.holding_period_high}.  Stop loss value: #{trade.stop_loss_value}."
        elsif trade.longshort == 'short'
          trade.note << "\n\n#{date} Stop loss signal.  Close: #{stock_date.close}.  Holding period low: #{trade.holding_period_low}.  Stop loss value: #{trade.stop_loss_value}."
        end
        trade.save!
      end
    end
  end


  def data_from_row row
    ticker = row['Ticker'].split(/\s+/)[0]
    country = row['Ticker'].split(/\s+/)[1]
    name = row['Short Name']
    industry_name = row['GICS Sector']
    return ticker, country, name, industry_name
  end

end
