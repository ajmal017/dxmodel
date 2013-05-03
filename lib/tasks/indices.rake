require 'httparty'

namespace :indices do

  desc "Update indices"
  task :update, [:index] => [:environment] do |task, args|
    index = args[:index].upcase
    url = "http://www.bloomberg.com/markets/chart/data/1Y/#{index}:IND"
    response = HTTParty.get(url)

    response['data_values'].each do |date_price|
      date = Time.at(date_price[0]/1000).to_date
      close = date_price[1]
      print "#{index} #{date}   "
      if IndexDate.where(index: index, date: date).present?
        puts 'exists'
      else
        IndexDate.create!(index: index, date: date, close: close)
        puts 'created'
      end
    end
  end
  
end
