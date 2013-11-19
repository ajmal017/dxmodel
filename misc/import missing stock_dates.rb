require 'csv'    
require 'debugger'    

csv_text = File.read('/tmp/missing.csv')
csv = CSV.parse(csv_text, :headers => true)

# Loop through stocks
csv.each do |row|
  ticker, country = row['Ticker Country'].split(' ')
  stock = Stock.where(ticker: ticker, country: country).first

  # Loop through dates
  csv.headers[1..-1].each do |date_header|
    close = row[date_header] 
    date = date_header.to_date
    stock_date = StockDate.where(date: date, stock_id: stock.id).first

    if close == "#N/A N/A"
    elsif stock_date.present?
      stock_date.update_attribute(:close, close)
    else
      stock_date = StockDate.create!(date: date, stock_id: stock.id, close: close)
    end
  end
  
end
