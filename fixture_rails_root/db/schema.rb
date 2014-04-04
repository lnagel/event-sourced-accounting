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

ActiveRecord::Schema.define(:version => 20120514173712) do

  create_table "esa_charts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "esa_charts", [:name], :name => "index_esa_charts_on_name"

  create_table "esa_accounts", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "type"
    t.boolean  "contra"
    t.integer  "chart_id"
    t.string   "normal_balance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "esa_accounts", ["name", "type", "chart_id"], :name => "index_esa_accounts_on_name_type_chart"

  create_table "esa_amounts", :force => true do |t|
    t.string  "type"
    t.integer "account_id"
    t.integer "transaction_id"
    t.decimal "amount",         :precision => 20, :scale => 10
  end

  add_index "esa_amounts", ["account_id", "transaction_id"], :name => "index_esa_amounts_on_account_id_and_transaction_id"
  add_index "esa_amounts", ["transaction_id", "account_id"], :name => "index_esa_amounts_on_transaction_id_and_account_id"
  add_index "esa_amounts", ["type"], :name => "index_esa_amounts_on_type"

  create_table "esa_transactions", :force => true do |t|
    t.string   "description"
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "esa_transactions", ["accountable_id", "accountable_type"], :name => "index_transactions_on_commercial_doc"

end
