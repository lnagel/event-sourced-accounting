class CreateEsaTables < ActiveRecord::Migration
  def self.up
    create_table :esa_charts do |t|
      t.string :name

      t.timestamps
    end
    add_index :esa_charts, [:name]

    create_table :esa_accounts do |t|
      t.string     :code
      t.string     :name
      t.string     :type
      t.boolean    :contra
      t.string     :normal_balance
      t.references :chart

      t.timestamps
    end
    add_index :esa_accounts, [:name, :type, :chart_id]
    add_index :esa_accounts, :normal_balance

    create_table :esa_events, :force => true do |t|
      t.string     :type
      t.datetime   :time
      t.string     :nature
      t.boolean    :processed
      t.references :accountable, :polymorphic => true
      t.references :ruleset

      t.timestamps
    end
    add_index :esa_events, :type
    add_index :esa_events, :time
    add_index :esa_events, :nature
    add_index :esa_events, [:accountable_id, :accountable_type], :name => "index_events_on_accountable"
    add_index :esa_events, :ruleset_id
    add_index :esa_events, [:time, :nature, :accountable_id, :accountable_type], :unique => true, :name => "unique_contents"

    create_table :esa_flags, :force => true do |t|
      t.string     :type
      t.datetime   :time
      t.string     :nature
      t.boolean    :state
      t.integer    :transition, :limit => 1
      t.boolean    :processed
      t.boolean    :adjusted
      t.datetime   :adjustment_time
      t.references :accountable, :polymorphic => true
      t.references :event
      t.references :ruleset

      t.timestamps
    end
    add_index :esa_flags, :type
    add_index :esa_flags, :time
    add_index :esa_flags, :nature
    add_index :esa_flags, [:accountable_id, :accountable_type], :name => "index_flags_on_accountable"
    add_index :esa_flags, :event_id
    add_index :esa_flags, :ruleset_id
    add_index :esa_flags, [:time, :nature, :accountable_id, :accountable_type], :unique => true, :name => "unique_contents"

    create_table :esa_transactions do |t|
      t.string     :type
      t.datetime   :time
      t.string     :description
      t.references :accountable, :polymorphic => true
      t.references :flag

      t.timestamps
    end
    add_index :esa_transactions, [:accountable_id, :accountable_type], :name => "index_transactions_on_accountable"
    add_index :esa_transactions, [:time, :description, :accountable_id, :accountable_type], :unique => true, :name => "unique_contents"

    create_table :esa_rulesets, :force => true do |t|
      t.string     :type
      t.string     :name
      t.references :chart

      t.timestamps
    end
    add_index :esa_rulesets, :type
    add_index :esa_rulesets, :chart_id

    create_table :esa_amounts do |t|
      t.string     :type
      t.references :account
      t.references :transaction
      t.decimal    :amount, :precision => 20, :scale => 10

      t.timestamps
    end 
    add_index :esa_amounts, :type
    add_index :esa_amounts, [:account_id, :transaction_id]
    add_index :esa_amounts, [:transaction_id, :account_id]
    add_index :esa_amounts, [:type, :account_id, :transaction_id, :amount], :unique => true, :name => "unique_contents"

    create_table :esa_contexts do |t|
      t.string     :type
      t.string     :name
      t.references :chart
      t.references :parent
      t.references :account
      t.references :accountable, :polymorphic => true
      t.string     :namespace
      t.date       :start_date
      t.date       :end_date

      t.datetime   :freshness
      t.decimal    :event_count,       :precision => 16
      t.decimal    :flag_count,        :precision => 16
      t.decimal    :transaction_count, :precision => 16
      t.decimal    :amount_count,      :precision => 16
      t.decimal    :debits_total,    :precision => 20, :scale => 10
      t.decimal    :credits_total,   :precision => 20, :scale => 10
      t.decimal    :opening_balance, :precision => 20, :scale => 10
      t.decimal    :closing_balance, :precision => 20, :scale => 10

      t.timestamps
    end
    add_index :esa_contexts, [:type, :chart_id]
    add_index :esa_contexts, :parent_id
    add_index :esa_contexts, :account_id
    add_index :esa_contexts, [:accountable_id, :accountable_type], :name => "index_contexts_on_accountable"
    add_index :esa_contexts, :namespace
    add_index :esa_contexts, :start_date
    add_index :esa_contexts, :end_date
    add_index :esa_contexts, :freshness
  end

  def self.down
    drop_table :esa_charts
    drop_table :esa_accounts
    drop_table :esa_events
    drop_table :esa_flags
    drop_table :esa_transactions
    drop_table :esa_rulesets
    drop_table :esa_amounts
    drop_table :esa_contexts
  end
end
