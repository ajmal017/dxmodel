# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130424065200) do

  create_table "fx_rates", :force => true do |t|
    t.date     "date"
    t.decimal  "usdsgd",     :precision => 14, :scale => 6
    t.decimal  "usdhkd",     :precision => 14, :scale => 6
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.decimal  "usdcny",     :precision => 14, :scale => 6
    t.decimal  "usdusd",     :precision => 14, :scale => 6, :default => 1.0
    t.decimal  "usdgbp",     :precision => 14, :scale => 6
    t.decimal  "usdeur",     :precision => 14, :scale => 6
    t.decimal  "usdjpy",     :precision => 14, :scale => 6
  end

  create_table "index_dates", :force => true do |t|
    t.string   "index"
    t.date     "date"
    t.float    "close",      :default => 0.0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "industries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "stock_dates", :force => true do |t|
    t.integer  "stock_id"
    t.date     "date"
    t.float    "long_fund_score",                                             :default => 0.0
    t.integer  "long_fund_rank_by_industry"
    t.integer  "long_fund_rank"
    t.string   "long_fund_signal"
    t.string   "long_tech_signal"
    t.float    "short_fund_score",                                            :default => 0.0
    t.integer  "short_fund_rank_by_industry"
    t.integer  "short_fund_rank"
    t.string   "short_fund_signal"
    t.string   "short_tech_signal"
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.decimal  "alpha",                        :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "per",                          :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "per_change",                   :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "pbr",                          :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "pbr_change",                   :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "pfcf",                         :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "pfcf_change",                  :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "eps_5yr_growth",               :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "roe_bf12m",                    :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "roa_bf12m",                    :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "average_traded_value_30_days", :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "close",                        :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "wmavg_10d",                    :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "smavg_10d",                    :precision => 20, :scale => 6, :default => 0.0
    t.decimal  "vwap",                         :precision => 20, :scale => 6, :default => 0.0
  end

  add_index "stock_dates", ["date"], :name => "index_stock_dates_on_date"
  add_index "stock_dates", ["stock_id"], :name => "index_stock_dates_on_stock_id"

  create_table "stocks", :force => true do |t|
    t.string   "ticker"
    t.string   "name"
    t.string   "country"
    t.integer  "industry_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "currency"
  end

  create_table "trades", :force => true do |t|
    t.string   "state"
    t.integer  "stock_id"
    t.string   "longshort"
    t.integer  "quantity"
    t.date     "enter_signal_date"
    t.date     "enter_date"
    t.decimal  "enter_local_price", :precision => 20, :scale => 6
    t.decimal  "enter_local_value", :precision => 20, :scale => 6
    t.decimal  "enter_usd_fx_rate", :precision => 14, :scale => 6
    t.decimal  "enter_usd_value",   :precision => 20, :scale => 6
    t.date     "exit_signal_date"
    t.date     "exit_date"
    t.decimal  "exit_local_price",  :precision => 20, :scale => 6
    t.decimal  "exit_local_value",  :precision => 20, :scale => 6
    t.decimal  "exit_usd_value",    :precision => 20, :scale => 6
    t.decimal  "exit_usd_fx_rate",  :precision => 14, :scale => 6
    t.string   "note"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "trades", ["enter_date"], :name => "index_trades_on_enter_date"
  add_index "trades", ["exit_date"], :name => "index_trades_on_exit_date"
  add_index "trades", ["state"], :name => "index_trades_on_state"
  add_index "trades", ["stock_id"], :name => "index_trades_on_stock_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
