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

ActiveRecord::Schema.define(:version => 20121209032339) do

  create_table "industries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stock_scores", :force => true do |t|
    t.integer  "stock_id"
    t.date     "date"
    t.float    "long_fund_score"
    t.float    "long_fund_rank_by_industry"
    t.float    "short_fund_score"
    t.float    "short_fund_rank_by_industry"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "long_fund_rank"
    t.integer  "short_fund_rank"
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
