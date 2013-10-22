#namespace :backtest do
#
#  desc "Backtest"
#  task :backtest => [:environment] do |task, args|
#    StockDate.transaction do
#
#      reset_trades && reset_signals
#
#      # Loop through days
#      dates = FxRate.unscoped.select('distinct date').order('date ASC').collect(&:date)
#      dates.each do |stock_date, index|
#
#        # Loop through stocks
#        Stock.all.each do |stock|
#        stock_date = StockDate.where({stock_id: stock.id, date: date}).first
#        next if stock_date.nil?  # skip unless we have rank data for stock on date
#
#        # Calc signals
#        stock_date.calc_fund_signals
#        stock_date.calc_ma_signals if MA
#        stock_date.calc_rsi_signals if RSI
#        stock_date.calc_tech_signals
#        stock_date.save!
#        puts "#{stock_date} - Fundamental and technical signals complete"
#
#        # Calc trades
#        Trade.propose_exits_missing_stocks date
#        Trade.propose_exits_fundamental date
#        Trade.propose_exits_stop_loss date
#        Trade.propose_entries_long date
#        Trade.propose_entries_short date
#        puts "#{stock_date} - Trade signals complete"
#
#        # Create trades
#        Trade.where(enter_signal_date: @date).each do |trade|
#
#          trade.enter_date = dates[index + 1]
#          trade.enter_usd_fx_rate =  FxRate.where(date: trade.enter_date).first.send("usd#{trade.stock.currency.downcase}")
#          trade.enter_local_price = StockDate.where(date: dates[index + 1], stock_id: trade.stock_id).first.close
#          trade.quantity = (MAX_PER_ENTRY / (trade.enter_local_price / trade.enter_usd_fx_rate)).floor
#          trade.enter_local_value = trade.quantity * trade.enter_local_price
#          trade.enter_usd_value = trade.enter_local_value / trade.enter_usd_fx_rate
#          trade.state = 'entered'
#        end
#        puts "#{stock_date} - Trades entered"
#
#        Trade.where(exit_signal_date: @date).each do |trade|
#          trade.exit_date = dates[index + 1]
#          trade.exit_usd_fx_rate =  FxRate.where(date: trade.exit_date).first.send("usd#{trade.stock.currency.downcase}")
#          trade.quantity = trade.enter_quantity
#          trade.exit_local_price = StockDate.where(date: dates[index + 1], stock_id: trade.stock_id).first.close
#          trade.exit_local_value = trade.quantity * trade.exit_local_price
#          trade.exit_usd_value = trade.exit_local_value / trade.exit_usd_fx_rate
#          trade.state = 'exited'
#        end
#        puts "#{stock_date} - Trades exited"
#      end
#    end
#  end
#  
#
#private
#
#  def reset_trades
#    Trade.destroy_all
#  end
#
#  def reset_signals
#    StockDate.update_all ma_long_enter: nil
#    StockDate.update_all ma_long_exit: nil
#    StockDate.update_all ma_short_enter: nil
#    StockDate.update_all ma_short_exit: nil
#
#    StockDate.update_all rsi_long_enter: nil
#    StockDate.update_all rsi_long_exit: nil
#    StockDate.update_all rsi_short_enter: nil
#    StockDate.update_all rsi_short_exit: nil
#
#    StockDate.update_all fund_long_enter: nil
#    StockDate.update_all fund_long_exit: nil
#    StockDate.update_all fund_short_enter: nil
#    StockDate.update_all fund_short_exit: nil
#
#    StockDate.update_all tech_long_enter: nil
#    StockDate.update_all tech_long_exit: nil
#    StockDate.update_all tech_short_enter: nil
#    StockDate.update_all tech_short_exit: nil
#  end
#
#end
