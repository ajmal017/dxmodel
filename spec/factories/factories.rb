FactoryGirl.define do

  factory :industry do 
    sequence(:name)
  end

  factory :stock do 
    industry
    sequence(:ticker)
    sequence(:name)
    country 'HK'
  end

  factory :stock_date do
    stock
    date 10.days.ago
#    long_fund_score
#    long_fund_rank_by_industry
#    long_fund_rank
#    long_fund_signal
#    long_tech_signal
#    short_fund_score
#    short_fund_rank_by_industry
#    short_fund_rank
#    short_fund_signal
#    short_tech_signal
#    close
#    wmavg_10d
#    smavg_10d
#    vwap
  end

  factory :trade do 
    stock

    trait :enter_signaled do state 'enter_signaled' end
    trait :entered do state 'entered' end
    trait :exit_signaled do state 'exit_signaled' end
    trait :exited do state 'exited' end

    trait :long do longshort 'long' end
    trait :short do longshort 'short' end


    quantity 10
    enter_signal_date 9.days.ago
    enter_date 8.days.ago
    enter_local_price 1.0
    enter_local_value 10.0
    enter_usd_fx_rate 2.0
    enter_usd_value 20.0

    exit_signal_date 4.days.ago
    exit_date 3.days.ago
    exit_local_price 1.5
    exit_local_value 15.0
    exit_usd_fx_rate 2.0
    exit_usd_value 30.0
  end

end
