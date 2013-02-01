module TradesHelper

  def usd_pnl_on_date_with_percentage trade, date
    pnl = trade.usd_pnl_on_date(date)
    klass = pnl > 0 ? 'positive' : 'negative'

    str = number_to_currency(trade.usd_pnl_on_date(date), :precision => 2) 
    str << '&nbsp;&nbsp;('.html_safe
    str << trade.usd_pnl_percentage_on_date(date).to_s
    str << '%)'

    haml_tag :span, str, :class => klass
  end

end
