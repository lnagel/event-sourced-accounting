require 'esa/associations/amounts_extension'

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
  # @author Lenno Nagel, Michael Bulat
  class Account < ActiveRecord::Base
    extend ::Enumerize

    attr_accessible :chart, :type, :code, :name, :contra
    attr_accessible :chart, :type, :code, :name, :contra, :as => :admin
    attr_readonly   :chart

    belongs_to :chart
    has_many :amounts, :extend => ESA::Associations::AmountsExtension
    has_many :transactions, :through => :amounts, :source => :transaction

    enumerize :normal_balance, in: [:none, :debit, :credit]

    after_initialize :initialize_defaults

    before_validation :update_normal_balance
    validates_presence_of :type, :name, :chart, :normal_balance
    validates_uniqueness_of :code, :scope => :chart_id, :allow_nil => true
    validates_uniqueness_of :name, :scope => :chart_id

    # The balance of the account.
    #
    # @example
    #   >> account.balance
    #   => #<BigDecimal:103259bb8,'0.2E4',4(12)>
    #
    # @return [BigDecimal] The decimal value balance
    def balance
      if self.normal_balance.debit?
        self.amounts.balance
      elsif self.normal_balance.credit?
        - self.amounts.balance
      else
        nil
      end
    end

    def self.valid_type?(type)
      type.in? ["Asset", "Liability", "Equity", "Revenue", "Expense"]
    end

    def self.namespaced_type(type)
      if valid_type?(type)
        "ESA::Accounts::#{type}"
      else
        type
      end
    end

    private

    def initialize_defaults
      self.chart ||= Chart.where(:name => 'Chart of Accounts').first_or_create if self.chart_id.nil?
      self.normal_balance ||= :none
    end

    # The normal balance for the account. Must be overridden in implementations.
    def update_normal_balance
      self.normal_balance = :none
    end
  end
end
