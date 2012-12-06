#!/usr/bin/env ruby
require 'csv'

ActiveRecord::Base.logger = nil

rows = []
file = '/Users/andywatts/Dropbox/Shares/Nilesh/Live Daily Ranking/20121205L.csv'
CSV.foreach(file) do |row|
  rows << row
end

basename = File.basename(file, 'L.csv')
date = Date.strptime(basename, "%Y%m%d")
puts "### Importing file #{file}"
puts "### Date: #{date.to_s}"


# Remove headings
rows.delete_at(0)

# Industries
puts "\n\n### Importing industries"
rows.each_with_index do |row, index|
  print "Row #{index.to_s} :"
  industry = Industry.new
  industry.name = row[2]
  if industry.valid?
    industry.save!
  else
    industry.errors.full_messages.each{|m|puts m}
  end 
end



# Stocks
puts "\n\n### Import stocks"
rows.each_with_index do |row, index|
  print "Row #{index.to_s} :"
  stock = Stock.new

  stock.ticker = row[0].split(/\s+/)[0]
  stock.country = row[0].split(/\s+/)[1]

  stock.name = row[1]

  industry = Industry.where(name: row[2]).first
  stock.industry = industry

  if stock.valid?
    stock.save! 
    puts "Saved" 

  else
    stock.errors.full_messages.each{|m|puts m}
  end
end



# Risk and funda screen 1
puts "\n\n### Import risk_and_funda_screen_1 scores"
rows.each_with_index do |row, index|
  print "Row #{index.to_s} :"
  stock_score = StockScore.new
  ticker = row[0].split(/\s+/)[0]
  country = row[0].split(/\s+/)[1]
  stock = Stock.where(ticker: ticker, country: country).first

  stock_score.stock = stock
  stock_score.fundamental_score = row[3]
  stock_score.date = date

  if stock_score.valid?
    stock_score.save! 
    puts "Saved" 
  else
    stock_score.errors.full_messages.each{|m|puts m}
  end
end



# Calc fundamentals_rank_by_industry
Industry.all.each do |industry|
  industry.stock_scores.where("stock_scores.date = '#{date}'").order('stock_scores.fundamental_score DESC').each_with_index do |stock_score, index|
    stock_score.fundamentals_rank_by_industry = index
    stock_score.save!
  end
end
