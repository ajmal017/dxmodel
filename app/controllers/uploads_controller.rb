class UploadsController < ApplicationController
  require 'csv'
  
  def new
  end


  def create
    unless params[:long] and params[:short] and params[:date]
      flash[:error] = "Failed to parse filename.  Does it follow this convention  20121205L.csv or 20121205S.csv?"
      redirect_to new_upload_path
    end
    date = params[:date]

    Stock.transaction do
      long = CSV.parse(params[:long].read)
      short = CSV.parse(params[:short].read)

      [long, short].each do |data|
        data.delete_at(0) # Remove headings
        create_industries data
        create_stocks data
        create_stock_dates data, date
      end

      import_stock_data long, date, 'long'
      import_stock_data short, date, 'short'

      calc_fund_ranks_by_industry date 

      calc_fund_ranks 'long', date 
      calc_fund_ranks 'short', date 

      calc_signals date

      propose_position_entries date
      propose_position_exits date
      propose_stop_loss_positions date

      flash[:success] = "Upload successful"
      redirect_to signaled_positions_path
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
      stock_date = StockDate.new(stock_id: stock.id, date: date) if stock_date.nil?
debugger unless stock_date.valid?
      stock_date.save!
    end
  end

  def import_stock_data rows, date, longshort
    rows.each_with_index do |row, index|
      ticker, country, name = data_from_row row
      stock = Stock.where(ticker: ticker, country: country).first

      stock_dates = StockDate.where({stock_id: stock.id, date: date}).first

      stock_dates.long_fund_score = row[3] if longshort == 'long'
      stock_dates.short_fund_score = row[3] if longshort == 'short'

      stock_dates.alpha =  ['','N.A.',nil].include?(row[4]) ? 0.0 : row[4]

      stock_dates.per =  ['','N.A.',nil].include?(row[5]) ? 0.0 : row[5]
      stock_dates.per_change =  ['','N.A.',nil].include?(row[6]) ? 0.0 : row[6]
     
      stock_dates.pbr =  ['','N.A.',nil].include?(row[7]) ? 0.0 : row[7]
      stock_dates.pbr_change =  ['','N.A.',nil].include?(row[8]) ? 0.0 : row[8]
     
      stock_dates.pfcf =  ['','N.A.',nil].include?(row[9]) ? 0.0 : row[9]
      stock_dates.pfcf_change =  ['','N.A.',nil].include?(row[10]) ? 0.0 : row[10]
     
      stock_dates.eps_5yr_growth =  ['','N.A.',nil].include?(row[11]) ? 0.0 : row[11]

      stock_dates.roe_bf12m =  ['','N.A.',nil].include?(row[12]) ? 0.0 : row[12]
      stock_dates.roa_bf12m =  ['','N.A.',nil].include?(row[13]) ? 0.0 : row[13]

      stock_dates.average_traded_value_30_days =  ['','N.A.',nil].include?(row[16]) ? 0.0 : row[16]

      stock_dates.close =  ['','N.A.',nil].include?(row[18]) ? 0.0 : row[18]

      stock_dates.wmavg_10d =  ['','N.A.',nil].include?(row[19]) ? 0.0 : row[19]
      stock_dates.smavg_10d =  ['','N.A.',nil].include?(row[22]) ? 0.0 : row[22]

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

  def calc_signals date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      # skip unless we have rank data for stock on date
      next if stock_date.nil? 

      if stock_date.long_fund_rank <= ENTER_RANK_THRESHOLD 
        stock_date.long_signal = 'ENTER'

      elsif stock_date.long_fund_rank > EXIT_RANK_THRESHOLD 
        stock_date.long_signal = 'EXIT'
      end

      if stock_date.short_fund_rank <= ENTER_RANK_THRESHOLD 
        stock_date.short_signal = 'ENTER'

      elsif stock_date.short_fund_rank > EXIT_RANK_THRESHOLD 
        stock_date.short_signal = 'EXIT'
      end

      stock_date.save!
    end
  end

  def propose_position_entries date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      next if stock_date.nil?  # skip unless we have rank data for stock on date
      
      if stock_date.long_signal == 'ENTER' and stock_date.short_signal == 'ENTER' 
        # Do nothing if signals say enter long and short

      elsif stock_date.long_signal == 'ENTER' 
        note = "#{date} Enter long signal.  Fund. rank #{stock_date.long_fund_rank}."
        position = Position.create!(stock_id: stock.id, longshort: 'long', enter_signal_date: date, note: note)

      elsif stock_date.short_signal == 'ENTER' 
        note = "#{date} Enter short signal.  Fund. rank #{stock_date.short_fund_rank}."
        position = Position.create!(stock_id: stock.id, longshort: 'short', enter_signal_date: date, note: note)
      end
    end
  end

  def propose_position_exits date
    Stock.all.each do |stock|
      stock_date = StockDate.where({stock_id: stock.id, date: date}).first
      next if stock_date.nil?  # skip unless we have rank data for stock on date

      if stock_date.long_signal == 'EXIT' and long_position = stock.positions.entered.long.try(:first)
        long_position.signal_exit!
        long_position.note << "\n#{date} Exit long signal.  Fund. rank #{stock_date.long_fund_rank}."
        long_position.save!

      elsif stock_date.short_signal == 'EXIT' and short_position = stock.positions.entered.short.try(:first)
        short_position.signal_exit!
        short_position.note << "\n#{date} Exit short signal.  Fund. rank #{stock_date.short_fund_rank}."
        short_position.save!
      end
    end
  end

  def propose_stop_loss_positions date
    Position.entered.each do |position|
      stock_date = StockDate.where(stock_id: position.stock_id, date: date)
      if position.stop_loss_triggered? stock_date.close
        position.signal_exit! 
        position.note << "\n#{date} Stop loss signal.  Close: #{stock_date.close}.  Holding period high: #{position.holding_period_high}.  Stop loss value: #{stop_loss_value}."
        short_position.save!
      end
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
