class CreateESATables < ActiveRecord::Migration
  def self.up
    create_table :esa_charts do |t|
      t.string :name

      t.timestamps
    end
    add_index :esa_charts, [:name]

    create_table :esa_accounts do |t|
      t.string :name
      t.string :type
      t.boolean :contra
      t.references :chart

      t.timestamps
    end
    add_index :esa_accounts, [:name, :type, :chart]

    create_table :esa_transactions do |t|
      t.string :description
      t.integer :commercial_document_id
      t.string :commercial_document_type
      t.datetime :time

      t.timestamps
    end
    add_index :esa_transactions, [:commercial_document_id, :commercial_document_type], :name => "index_transactions_on_commercial_doc"

    create_table :esa_amounts do |t|
      t.string :type
      t.references :account
      t.references :transaction
      t.decimal :amount, :precision => 20, :scale => 10
    end 
    add_index :esa_amounts, :type
    add_index :esa_amounts, [:account_id, :transaction_id]
    add_index :esa_amounts, [:transaction_id, :account_id]
  end

  def self.down
    drop_table :esa_charts
    drop_table :esa_accounts
    drop_table :esa_transactions
    drop_table :esa_amounts
  end
end
