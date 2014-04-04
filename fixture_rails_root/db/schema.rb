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

ActiveRecord::Schema.define(:version => 20140404075330) do

  create_table "esa_accounts", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "type"
    t.boolean  "contra"
    t.string   "normal_balance"
    t.integer  "chart_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "esa_accounts", ["name", "type", "chart_id"], :name => "index_esa_accounts_on_name_and_type_and_chart_id"
  add_index "esa_accounts", ["normal_balance"], :name => "index_esa_accounts_on_normal_balance"

  create_table "esa_amounts", :force => true do |t|
    t.string   "type"
    t.integer  "account_id"
    t.integer  "transaction_id"
    t.decimal  "amount",         :precision => 20, :scale => 10
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "esa_amounts", ["account_id", "transaction_id"], :name => "index_esa_amounts_on_account_id_and_transaction_id"
  add_index "esa_amounts", ["transaction_id", "account_id"], :name => "index_esa_amounts_on_transaction_id_and_account_id"
  add_index "esa_amounts", ["type", "account_id", "transaction_id", "amount"], :name => "unique_contents_on_amounts", :unique => true
  add_index "esa_amounts", ["type"], :name => "index_esa_amounts_on_type"

  create_table "esa_charts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "esa_charts", ["name"], :name => "index_esa_charts_on_name"

  create_table "esa_contexts", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "chart_id"
    t.integer  "parent_id"
    t.integer  "account_id"
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.string   "namespace"
    t.integer  "position"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "freshness"
    t.decimal  "event_count",       :precision => 16, :scale => 0
    t.decimal  "flag_count",        :precision => 16, :scale => 0
    t.decimal  "transaction_count", :precision => 16, :scale => 0
    t.decimal  "amount_count",      :precision => 16, :scale => 0
    t.decimal  "debits_total",      :precision => 20, :scale => 10
    t.decimal  "credits_total",     :precision => 20, :scale => 10
    t.decimal  "opening_balance",   :precision => 20, :scale => 10
    t.decimal  "closing_balance",   :precision => 20, :scale => 10
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "esa_contexts", ["account_id"], :name => "index_esa_contexts_on_account_id"
  add_index "esa_contexts", ["accountable_id", "accountable_type"], :name => "index_accountable_on_contexts"
  add_index "esa_contexts", ["end_date"], :name => "index_esa_contexts_on_end_date"
  add_index "esa_contexts", ["freshness"], :name => "index_esa_contexts_on_freshness"
  add_index "esa_contexts", ["namespace"], :name => "index_esa_contexts_on_namespace"
  add_index "esa_contexts", ["parent_id"], :name => "index_esa_contexts_on_parent_id"
  add_index "esa_contexts", ["start_date"], :name => "index_esa_contexts_on_start_date"
  add_index "esa_contexts", ["type", "chart_id"], :name => "index_esa_contexts_on_type_and_chart_id"

  create_table "esa_events", :force => true do |t|
    t.string   "type"
    t.datetime "time"
    t.string   "nature"
    t.boolean  "processed"
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.integer  "ruleset_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "esa_events", ["accountable_id", "accountable_type"], :name => "index_accountable_on_events"
  add_index "esa_events", ["nature"], :name => "index_esa_events_on_nature"
  add_index "esa_events", ["ruleset_id"], :name => "index_esa_events_on_ruleset_id"
  add_index "esa_events", ["time", "nature", "accountable_id", "accountable_type"], :name => "unique_contents_on_events", :unique => true
  add_index "esa_events", ["time"], :name => "index_esa_events_on_time"
  add_index "esa_events", ["type"], :name => "index_esa_events_on_type"

  create_table "esa_flags", :force => true do |t|
    t.string   "type"
    t.datetime "time"
    t.string   "nature"
    t.boolean  "state"
    t.integer  "transition",       :limit => 1
    t.boolean  "processed"
    t.boolean  "adjusted"
    t.datetime "adjustment_time"
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.integer  "event_id"
    t.integer  "ruleset_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "esa_flags", ["accountable_id", "accountable_type"], :name => "index_accountable_on_flags"
  add_index "esa_flags", ["event_id"], :name => "index_esa_flags_on_event_id"
  add_index "esa_flags", ["nature"], :name => "index_esa_flags_on_nature"
  add_index "esa_flags", ["ruleset_id"], :name => "index_esa_flags_on_ruleset_id"
  add_index "esa_flags", ["time", "nature", "accountable_id", "accountable_type"], :name => "unique_contents_on_flags", :unique => true
  add_index "esa_flags", ["time"], :name => "index_esa_flags_on_time"
  add_index "esa_flags", ["type"], :name => "index_esa_flags_on_type"

  create_table "esa_rulesets", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "chart_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "esa_rulesets", ["chart_id"], :name => "index_esa_rulesets_on_chart_id"
  add_index "esa_rulesets", ["type"], :name => "index_esa_rulesets_on_type"

  create_table "esa_transactions", :force => true do |t|
    t.string   "type"
    t.datetime "time"
    t.string   "description"
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.integer  "flag_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "esa_transactions", ["accountable_id", "accountable_type"], :name => "index_accountable_on_transactions"
  add_index "esa_transactions", ["time", "description", "accountable_id", "accountable_type"], :name => "unique_contents_on_transactions", :unique => true

end
