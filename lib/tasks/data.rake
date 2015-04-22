require 'csv'
include ActionView::Helpers::DateHelper

namespace :data do
  desc "validate"
  task :validate => [:environment] do |task, args|
    puts "wmavg_10d"
    nils = StockDate.where(wmavg_10d: nil).count 
    zeros = StockDate.where(wmavg_10d: 0.0).count
    puts "  Missing #{(nils + zeros).to_s} records (#{nils.to_s} nils; #{zeros.to_s} zeros)"


    puts "smavg_10d"
    nils = StockDate.where(smavg_10d: nil).count 
    zeros = StockDate.where(smavg_10d: 0.0).count
    puts "  Missing #{(nils + zeros).to_s} records (#{nils.to_s} nils; #{zeros.to_s} zeros)"

    puts "vwap"
    nils = StockDate.where(vwap: nil).count 
    zeros = StockDate.where(vwap: 0.0).count
    puts "  Missing #{(nils + zeros).to_s} records (#{nils.to_s} nils; #{zeros.to_s} zeros)"

    puts "close"
    nils = StockDate.where(close: nil).count 
    zeros = StockDate.where(close: 0.0).count
    puts "  Missing #{(nils + zeros).to_s} records (#{nils.to_s} nils; #{zeros.to_s} zeros)"
  end

  desc "import wma"
  task :import_wma => [:environment] do |task, args|
    csv_text = File.read('/tmp/sma.csv')
    csv = CSV.parse(csv_text, :headers => true)

    # Loop through rows
    csv.each do |row|

      # If row with stock name - set stock vars
      if row[0] != 'SMAVG' and row[0] != nil
        ticker = row[0].split(/\s+/)[0]
        country = row[0].split(/\s+/)[1]
        raise "failed to get ticker and country for #{row[0]}" unless ticker.present? and country.present?
        @stock = Stock.where(ticker: ticker, country: country).try(:first)
        raise "Stock not found #{ticker} #{country}" unless @stock.present?
        puts @stock.country_ticker
      end

      # If row with moving average- set stock date
      if row[0] == 'SMAVG'
        csv.headers[1..-1].each do |date|
          if row[date].present?
            date_db = Date.strptime(date, "%d/%m/%y").to_s(:db)
            stock_date = StockDate.where(stock_id: @stock.id, date: date_db).try(:first)
            if stock_date.present? and stock_date.smavg_10d.to_s != row[date].to_s
              stock_date.update_attribute(:smavg_10d, row[date])
              puts "Updating stock date for #{ticker} #{country} #{date}" 
            end
          end
        end
      end
    end
  end

end
