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

ActiveRecord::Schema.define(:version => 20130108130915) do

  create_table "industries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "positions", :force => true do |t|
    t.string   "state"
    t.integer  "stock_id"
    t.string   "longshort"
    t.integer  "quantity"
    t.date     "enter_signal_date"
    t.date     "enter_date"
    t.decimal  "enter_local_price", :precision => 8,  :scale => 6
    t.decimal  "enter_local_value", :precision => 14, :scale => 6
    t.decimal  "enter_usd_fx_rate", :precision => 14, :scale => 6
    t.decimal  "enter_usd_value",   :precision => 14, :scale => 6
    t.date     "exit_signal_date"
    t.date     "exit_date"
    t.decimal  "exit_local_price",  :precision => 14, :scale => 6
    t.decimal  "exit_local_value",  :precision => 14, :scale => 6
    t.decimal  "exit_usd_value",    :precision => 14, :scale => 6
    t.decimal  "exit_usd_fx_rate",  :precision => 14, :scale => 6
    t.string   "note"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

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
    t.string   "open_position"
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.decimal  "alpha",                        :precision => 4,  :scale => 4, :default => 0.0
    t.decimal  "per",                          :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "per_change",                   :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "pbr",                          :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "pbr_change",                   :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "pfcf",                         :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "pfcf_change",                  :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "eps_5yr_growth",               :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "roe_bf12m",                    :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "roa_bf12m",                    :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "average_traded_value_30_days", :precision => 12, :scale => 4, :default => 0.0
    t.decimal  "close",                        :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "wmavg_10d",                    :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "smavg_10d",                    :precision => 8,  :scale => 4, :default => 0.0
    t.decimal  "vwap",                         :precision => 8,  :scale => 6
  end

  create_table "stocks", :force => true do |t|
    t.string   "ticker"
    t.string   "name"
    t.string   "country"
    t.integer  "industry_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
