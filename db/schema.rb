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

ActiveRecord::Schema.define(:version => 20121219135957) do

  create_table "industries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stock_dates", :force => true do |t|
    t.integer  "stock_id"
    t.date     "date"
    t.float    "long_fund_score",                                             :default => 0.0
    t.integer  "long_fund_rank_by_industry"
    t.integer  "long_fund_rank"
    t.string   "long_signal"
    t.float    "short_fund_score",                                            :default => 0.0
    t.integer  "short_fund_rank_by_industry"
    t.integer  "short_fund_rank"
    t.string   "short_signal"
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
