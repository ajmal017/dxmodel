class RemoveDefaults < ActiveRecord::Migration
  def change
    cols = [
      :close,
      :smavg_10d,
      :wmavg_10d,
      :average_traded_value_30_days,

      :ma_long_enter,     
      :ma_long_exit,      
      :ma_short_enter,    
      :ma_short_exit,     

      :rsi_long_enter,    
      :rsi_long_exit,     
      :rsi_short_enter,   
      :rsi_short_exit,    

      :fund_long_enter,   
      :fund_long_exit,    
      :fund_short_enter,  
      :fund_short_exit,   

      :fund_long_enter,   
      :fund_long_exit,    
      :fund_short_enter,  
      :fund_short_exit,

      :tech_long_enter,   
      :tech_long_exit,    
      :tech_short_enter,  
      :tech_short_exit,

      :long_fund_score,
      :short_fund_score,

      :alpha,
      :per,
      :per_change,
      :pbr,
      :pbr_change,
      :pfcf,
      :pfcf_change,
      :eps_5yr_growth,

      :roe_bf12m,
      :roa_bf12m,

      :vwap
    ]

    cols.each do |col|
      change_column_default(:stock_dates, col, nil)
    end
  end
end
