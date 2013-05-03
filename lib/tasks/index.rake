require 'httparty'

namespace :index do

  desc "Update index"
  task :update => [:environment] do |task, args|
    url = "http://www.bloomberg.com/markets/chart/data/1Y/#{INDEX_TICKER}:IND"
    response = HTTParty.get(url)

    response['data_values'].each do |date_price|
      date = Time.at(date_price[0]/1000).to_date
      close = date_price[1]
      print "#{INDEX_TICKER} #{date}   "
      if IndexDate.where(index: INDEX_TICKER, date: date).present?
        puts 'exists'
      else
        IndexDate.create!(index: INDEX_TICKER, date: date, close: close)
        puts 'created'
      end
    end
  end
  
end
