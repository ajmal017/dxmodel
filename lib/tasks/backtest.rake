include ActionView::Helpers::DateHelper

namespace :backtest do
  desc "Splits"
  task :splits => [:environment] do |task, args|
    Stock.order('country ASC, ticker ASC').to_a.each do |stock|
      stock.stock_dates.order('date ASC').each_with_index do |stock_date, index|
        unless index == 0 or stock_date.close.nil? or @yesterday_close.nil?
          puts "#{stock.country_ticker} #{stock_date.date} #{@yesterday_close} #{stock_date.close}" if (stock_date.close - @yesterday_close).to_f/stock_date.close.to_f > 0.4
        end
        @yesterday_close = stock_date.close
      end
    end
  end



  desc "Backtest"
  task :backtest => [:environment] do |task, args|
    time = Time.now

    wipe_trades && wipe_signals

    # Loop through days
    dates = FxRate.unscoped.select('distinct date').order('date ASC').collect(&:date)
    dates.each_with_index do |date, index|

      # Stock signals
      print "\n#{date.to_s} - Stock signals"
      Stock.order('country ASC, ticker ASC').to_a.each do |stock|
        stock_date = StockDate.where({stock_id: stock.id, date: date}).first
        next if stock_date.nil?  # skip unless we have rank data for stock on date

        # Calc signals
        #stock_date.calc_fund_signals
        stock_date.calc_ma_signals if MA
        stock_date.calc_rsi_signals if RSI
        stock_date.calc_tech_signals
        stock_date.save!
        print '.'
        #puts "#{date.to_s} - #{stock.country_ticker} signals complete"
      end


      # Trade signals
      if StockDate.where(date: date).present?
        Trade.propose_exits_missing_stocks date
        #Trade.propose_exits_fundamental date
        Trade.propose_exits_stop_loss date
        Trade.propose_entries_long date
        Trade.propose_entries_short date
        puts "\n#{date.to_s} - Trade signals complete"
      end


      # Create trades
      Trade.enter_signaled.each do |trade|
        stock_date = StockDate.where(date: dates[index + 1], stock_id: trade.stock_id).first.try(:close)
        if stock_date.present?
          trade.enter_date = dates[index + 1]
          trade.enter_usd_fx_rate =  FxRate.where(date: trade.enter_date).first.send("usd#{trade.stock.currency.downcase}")
          trade.enter_local_price = StockDate.where(date: dates[index + 1], stock_id: trade.stock_id).first.close
          trade.quantity = (MAX_PER_ENTRY / (trade.enter_local_price / trade.enter_usd_fx_rate)).floor
          trade.enter_local_value = trade.quantity * trade.enter_local_price
          trade.enter_usd_value = trade.enter_local_value / trade.enter_usd_fx_rate
          trade.state = 'entered'
          trade.save!
        else
          trade.destroy!
        end
      end

      Trade.exit_signaled.each do |trade|
        stock_date = StockDate.where(date: dates[index + 1], stock_id: trade.stock_id).first.try(:close)
        if stock_date.present?
          trade.exit_date = dates[index + 1]
          trade.exit_usd_fx_rate =  FxRate.where(date: trade.exit_date).first.send("usd#{trade.stock.currency.downcase}")
          trade.exit_local_price = StockDate.where(date: dates[index + 1], stock_id: trade.stock_id).first.close
          trade.exit_local_value = trade.quantity * trade.exit_local_price
          trade.exit_usd_value = trade.exit_local_value / trade.exit_usd_fx_rate
          trade.state = 'exited'
          trade.save!
        else
          trade.exit_signal_date = nil
          trade.state = 'entered'
          trade.save!
        end
      end
      puts "#{date.to_s} - Trades entered and exited"
    end
    puts "Run time: " + distance_of_time_in_words_to_now(time).to_s
  end

private

  def wipe_trades
    puts "Wiping trades."
    Trade.destroy_all
  end

  def wipe_signals
    puts "Wiping StockDate signals"
    StockDate.update_all ma_long_enter: false
    StockDate.update_all ma_long_exit: false
    StockDate.update_all ma_short_enter: false
    StockDate.update_all ma_short_exit: false

    StockDate.update_all rsi_long_enter: false
    StockDate.update_all rsi_long_exit: false
    StockDate.update_all rsi_short_enter: false
    StockDate.update_all rsi_short_exit: false

    StockDate.update_all fund_long_enter: false
    StockDate.update_all fund_long_exit: false
    StockDate.update_all fund_short_enter: false
    StockDate.update_all fund_short_exit: false

    StockDate.update_all tech_long_enter: false
    StockDate.update_all tech_long_exit: false
    StockDate.update_all tech_short_enter: false
    StockDate.update_all tech_short_exit: false
  end

end
