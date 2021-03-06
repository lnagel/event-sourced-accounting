require 'esa/associations/amounts_extension'
require 'esa/traits/extendable'

module ESA
  # The Chart class represents an organized set of accounts in the system.
  #
  # @author Lenno Nagel
  class Chart < ActiveRecord::Base
    include ESA::Traits::Extendable

    attr_accessible :name

    has_many :accounts
    has_many :rulesets

    has_many :events, :through => :rulesets, :uniq => true
    has_many :flags, :through => :rulesets, :uniq => true
    has_many :transactions, :through => :accounts, :uniq => true
    has_many :amounts, :through => :accounts, :uniq => true, :extend => ESA::Associations::AmountsExtension

    after_initialize :initialize_defaults

    validates_presence_of :name
    validates_uniqueness_of :name

    # The trial balance of all accounts in the system. This should always equal zero,
    # otherwise there is an error in the system.
    #
    # @example
    #   >> chart.trial_balance.to_i
    #   => 0
    #
    # @return [BigDecimal] The decimal value balance of all accounts
    def trial_balance
      self.amounts.balance
    end

    private

    def initialize_defaults
      self.name ||= "Chart of Accounts"
    end
  end
end
