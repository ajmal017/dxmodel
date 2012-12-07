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
        date = params[:date]
        rows = CSV.parse(params[:file].read)
        rows.delete_at(0) # Remove headings

        import_industries rows     
        import_stocks rows     
        import_fund_scores rows, date, params[:longshort]

        calc_long_fund_ranks date if params[:longshort] == 'long'
        calc_short_fund_ranks date if params[:longshort] == 'short'

        flash[:success] = "Upload successful"
        redirect_to reports_path(:longshort => params[:longshort])
      end
    end
  end


private

  def import_industries rows
    rows.each_with_index do |row, index|
      industry = Industry.new
      industry.name = row[2]
      industry.save!  if industry.valid?
    end
  end  

  def import_stocks rows
    rows.each_with_index do |row, index|
      stock = Stock.new
      stock.ticker = row[0].split(/\s+/)[0]
      stock.country = row[0].split(/\s+/)[1]
      stock.name = row[1]
      industry = Industry.where(name: row[2]).first
      stock.industry = industry
      stock.save!  if stock.valid?
    end
  end

  def import_fund_scores rows, date, longshort
    rows.each_with_index do |row, index|
      ticker = row[0].split(/\s+/)[0]
      country = row[0].split(/\s+/)[1]
      stock = Stock.where(ticker: ticker, country: country).first

      # find or new
      stock_score = StockScore.where({stock_id: stock.id, date: date}).first
      stock_score = StockScore.new(date: date, stock_id: stock.id) if stock_score.nil?

      stock_score.long_fund_score = row[3] if longshort == 'long'
      stock_score.short_fund_score = row[3] if longshort == 'short'

      stock_score.save! if stock_score.valid?
    end
  end

  def calc_long_fund_ranks date
    Industry.all.each do |industry|
      industry.stock_scores.where("stock_scores.date = '#{date}'").order('stock_scores.long_fund_score DESC').each_with_index do |stock_score, index|
        stock_score.long_fund_rank_by_industry = index
        stock_score.save!
      end
    end
  end

  def calc_short_fund_ranks date
    Industry.all.each do |industry|
      industry.stock_scores.where("stock_scores.date = '#{date}'").order('stock_scores.short_fund_score DESC').each_with_index do |stock_score, index|
        stock_score.short_fund_rank_by_industry = index
        stock_score.save!
      end
    end
  end

end
