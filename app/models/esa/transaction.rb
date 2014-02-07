module ESA
  # Transactions are the recording of debits and credits to various accounts.
  # This table can be thought of as a traditional accounting Journal.
  #
  # Posting to a Ledger can be considered to happen automatically, since
  # Accounts have the reverse 'has_many' relationship to either it's credit or
  # debit transactions
  #
  # @example
  #   cash = ESA::Asset.find_by_name('Cash')
  #   accounts_receivable = ESA::Asset.find_by_name('Accounts Receivable')
  #
  #   debit_amount = ESA::DebitAmount.new(:account => cash, :amount => 1000)
  #   credit_amount = ESA::CreditAmount.new(:account => accounts_receivable, :amount => 1000)
  #
  #   transaction = ESA::Transaction.new(:description => "Receiving payment on an invoice")
  #   transaction.debit_amounts << debit_amount
  #   transaction.credit_amounts << credit_amount
  #   transaction.save
  #
  # @see http://en.wikipedia.org/wiki/Journal_entry Journal Entry
  #
  # @author Michael Bulat
  class Transaction < ActiveRecord::Base
    include Extendable

    attr_accessible :description, :accountable, :time

    belongs_to :flag, :foreign_key => :accountable_id
    belongs_to :accountable, :polymorphic => true
    has_many :credit_amounts, :inverse_of => :transaction, :class_name => "Amounts::CreditAmount", :extend => Associations::AmountsExtension
    has_many :debit_amounts, :inverse_of => :transaction, :class_name => "Amounts::DebitAmount", :extend => Associations::AmountsExtension
    has_many :credit_accounts, :through => :credit_amounts, :source => :account
    has_many :debit_accounts, :through => :debit_amounts, :source => :account

    after_initialize :default_values

    validates_presence_of :time, :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :accounts_of_the_same_chart?
    validate :amounts_cancel?
    
    # Support construction using 'credits' and 'debits' keys
    accepts_nested_attributes_for :credit_amounts, :debit_amounts
    alias_method :credits=, :credit_amounts_attributes=
    alias_method :debits=, :debit_amounts_attributes=
    attr_accessible :credits, :debits
    
    # Support the deprecated .build method
    def self.build(hash)
      ActiveSupport::Deprecation.warn("ESA::Transaction.build() is deprecated (use new instead)", caller)
      new(hash)
    end

    private
      def default_values
        self.time ||= Time.zone.now
        #self.ruleset ||= Ruleset.extension_class(self).fetch
      end

      def has_credit_amounts?
        errors[:base] << "Transaction must have at least one credit amount" if self.credit_amounts.blank?
      end

      def has_debit_amounts?
        errors[:base] << "Transaction must have at least one debit amount" if self.debit_amounts.blank?
      end

      def accounts_of_the_same_chart?
        chart_ids = (self.credit_amounts + self.debit_amounts).map{|a| a.account.chart_id}
        if chart_ids.compact.count != chart_ids.count or chart_ids.compact.uniq.count != 1
          errors[:base] << "Transaction must take place between accounts of the same Chart " + chart_ids.to_s
        end
      end

      def amounts_cancel?
        errors[:base] << "The credit and debit amounts are not equal" if credit_amounts.balance != debit_amounts.balance
      end
  end
end
