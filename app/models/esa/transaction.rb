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
  #   debit_amount = ESA::Amounts::Debit.new(:account => cash, :amount => 1000)
  #   credit_amount = ESA::Amounts::Credit.new(:account => accounts_receivable, :amount => 1000)
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
    include Traits::Extendable

    attr_accessible :description, :accountable, :flag, :time
    attr_readonly   :description, :accountable, :flag, :time

    belongs_to :accountable, :polymorphic => true
    belongs_to :flag
    has_many :amounts, :extend => Associations::AmountsExtension
    has_many :accounts, :through => :amounts, :source => :account, :uniq => true

    after_initialize :default_values

    validates_presence_of :time, :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :accounts_of_the_same_chart?
    validate :amounts_cancel?

    attr_accessible :credits, :debits

    def credits=(*attributes)
      attributes.flatten.each do |attrs|
        attrs[:transaction] = self
        self.amounts << Amounts::Credit.new(attrs)
      end
    end

    def debits=(*attributes)
      attributes.flatten.each do |attrs|
        attrs[:transaction] = self
        self.amounts << Amounts::Debit.new(attrs)
      end
    end

    private

    def default_values
      self.time ||= Time.zone.now
    end

    def has_credit_amounts?
      errors[:base] << "Transaction must have at least one credit amount" if self.amounts.find{|a| a.is_credit?}.nil?
    end

    def has_debit_amounts?
      errors[:base] << "Transaction must have at least one debit amount" if self.amounts.find{|a| a.is_debit?}.nil?
    end

    def accounts_of_the_same_chart?
      if self.new_record?
        chart_ids = self.amounts.map{|a| if a.account.present? then a.account.chart_id else nil end}
      else
        chart_ids = self.accounts.pluck(:chart_id)
      end

      if not chart_ids.all? or chart_ids.uniq.count != 1
        errors[:base] << "Transaction must take place between accounts of the same Chart " + chart_ids.to_s
      end
    end

    def amounts_cancel?
      errors[:base] << "The credit and debit amounts are not equal" if self.amounts.iterated_balance != 0
    end
  end
end
