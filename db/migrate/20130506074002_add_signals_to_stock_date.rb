class AddSignalsToStockDate < ActiveRecord::Migration
  def change
    add_column :stock_dates, :ma_long_enter, :boolean
    add_column :stock_dates, :ma_long_exit, :boolean
    add_column :stock_dates, :ma_short_enter, :boolean
    add_column :stock_dates, :ma_short_exit, :boolean

    add_column :stock_dates, :rsi_long_enter, :boolean
    add_column :stock_dates, :rsi_long_exit, :boolean
    add_column :stock_dates, :rsi_short_enter, :boolean
    add_column :stock_dates, :rsi_short_exit, :boolean


    add_column :stock_dates, :fund_long_enter, :boolean
    add_column :stock_dates, :fund_long_exit, :boolean
    add_column :stock_dates, :fund_short_enter, :boolean
    add_column :stock_dates, :fund_short_exit, :boolean


    add_column :stock_dates, :tech_long_enter, :boolean
    add_column :stock_dates, :tech_long_exit, :boolean
    add_column :stock_dates, :tech_short_enter, :boolean
    add_column :stock_dates, :tech_short_exit, :boolean


    execute "UPDATE stock_dates SET fund_long_enter = 1 WHERE long_fund_signal = 'ENTER'"
    execute "UPDATE stock_dates SET fund_long_exit = 1 WHERE long_fund_signal = 'EXIT'"

    execute "UPDATE stock_dates SET fund_short_enter = 1 WHERE short_fund_signal = 'ENTER'"
    execute "UPDATE stock_dates SET fund_short_exit = 1 WHERE short_fund_signal = 'EXIT'"

    remove_column :stock_dates, :short_fund_signal
    remove_column :stock_dates, :long_fund_signal
    remove_column :stock_dates, :short_tech_signal
    remove_column :stock_dates, :long_tech_signal
  end
end
