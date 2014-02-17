module ESA
  # The Account class represents accounts in the system. Each account must be subclassed as one of the following types:
  #
  #   TYPE        | NORMAL BALANCE    | DESCRIPTION
  #   --------------------------------------------------------------------------
  #   Asset       | Debit             | Resources owned by the Business Entity
  #   Liability   | Credit            | Debts owed to outsiders
  #   Equity      | Credit            | Owners rights to the Assets
  #   Revenue     | Credit            | Increases in owners equity
  #   Expense     | Debit             | Assets or services consumed in the generation of revenue
  #
  # Each account can also be marked as a "Contra Account". A contra account will have it's
  # normal balance swapped. For example, to remove equity, a "Drawing" account may be created
  # as a contra equity account as follows:
  #
  #   ESA::Equity.create(:name => "Drawing", contra => true)
  #
  # At all times the balance of all accounts should conform to the "accounting equation"
  #   ESA::Assets = Liabilties + Owner's Equity
  #
  # Each sublclass account acts as it's own ledger. See the individual subclasses for a
  # description.
  #
  # @abstract
  #   An account must be a subclass to be saved to the database. The Account class
  #   has a singleton method {trial_balance} to calculate the balance on all Accounts.
  #
  # @see http://en.wikipedia.org/wiki/Accounting_equation Accounting Equation
  # @see http://en.wikipedia.org/wiki/Debits_and_credits Debits, Credits, and Contra Accounts
  #
  # @author Michael Bulat
  class Account < ActiveRecord::Base
    extend ::Enumerize

    attr_accessible :chart, :type, :name, :contra
    attr_readonly   :chart

    belongs_to :chart
    has_many :amounts, :extend => Associations::AmountsExtension
    has_many :credit_amounts, :class_name => "Amounts::Credit", :extend => Associations::AmountsExtension
    has_many :debit_amounts, :class_name => "Amounts::Debit", :extend => Associations::AmountsExtension
    has_many :transactions, :through => :amounts, :source => :transaction
    has_many :credit_transactions, :through => :credit_amounts, :source => :transaction
    has_many :debit_transactions, :through => :debit_amounts, :source => :transaction

    enumerize :normal_balance, in: [:none, :debit, :credit]

    after_initialize :default_values

    before_validation :update_normal_balance
    validates_presence_of :type, :name, :chart, :normal_balance
    validates_uniqueness_of :name, :scope => :chart_id

    # The credit balance for the account.
    #
    # @example
    #   >> asset.credits_total
    #   => #<BigDecimal:103259bb8,'0.1E4',4(12)>
    #
    # @return [BigDecimal] The decimal value credit balance
    def credits_total
      credit_amounts.total
    end

    # The debit balance for the account.
    #
    # @example
    #   >> asset.debits_total
    #   => #<BigDecimal:103259bb8,'0.3E4',4(12)>
    #
    # @return [BigDecimal] The decimal value credit balance
    def debits_total
      debit_amounts.total
    end

    # The balance of the account.
    #
    # @example
    #   >> account.balance
    #   => #<BigDecimal:103259bb8,'0.2E4',4(12)>
    #
    # @return [BigDecimal] The decimal value balance
    def balance
      if self.normal_balance.debit?
        self.debits_total - self.credits_total
      elsif self.normal_balance.credit?
        self.credits_total - self.debits_total
      else
        nil
      end
    end

    def self.valid_type?(type)
      type.in? ["Asset", "Liability", "Equity", "Revenue", "Expense"]
    end

    def self.namespaced_type(type)
      if valid_type?(type)
        "ESA::Accounts::#{type}".constantize
      else
        type
      end
    end

    # The trial balance of all accounts in the system. This should always equal zero,
    # otherwise there is an error in the system.
    #
    # @example
    #   >> Account.trial_balance.to_i
    #   => 0
    #
    # @return [BigDecimal] The decimal value balance of all accounts
    def self.trial_balance
      unless self.new.class == Account
        raise(NoMethodError, "undefined method 'trial_balance'")
      else
        Accounts::Asset.balance - (Accounts::Liability.balance + Accounts::Equity.balance + Accounts::Revenue.balance - Accounts::Expense.balance)
      end
    end

    private

    def default_values
      self.chart ||= Chart.where(:name => 'Chart of Accounts').first_or_create
      self.normal_balance ||= :none
    end

    # The normal balance for the account. Must be overridden in implementations.
    def update_normal_balance
      self.normal_balance = :none
    end
  end
end
