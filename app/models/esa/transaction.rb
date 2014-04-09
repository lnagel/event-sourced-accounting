require 'esa/associations/amounts_extension'
require 'esa/traits/extendable'

module ESA
  # Transactions are the recording of debits and credits to various accounts.
  # This table can be thought of as a traditional accounting Journal.
  #
  # Transactions are created from transitions in the corresponding Flag.
  #
  # @author Lenno Nagel, Michael Bulat
  class Transaction < ActiveRecord::Base
    include ESA::Traits::Extendable

    attr_accessible :description, :accountable, :flag, :time
    attr_readonly   :description, :accountable, :flag, :time

    belongs_to :accountable, :polymorphic => true
    belongs_to :flag
    has_many :amounts, :extend => ESA::Associations::AmountsExtension
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
        self.amounts << ESA::Amounts::Credit.new(attrs)
      end
    end

    def debits=(*attributes)
      attributes.flatten.each do |attrs|
        attrs[:transaction] = self
        self.amounts << ESA::Amounts::Debit.new(attrs)
      end
    end

    def spec
      {
        :time => self.time,
        :description => self.description,
        :credits => self.amounts.credits.map{|a| {:account => a.account, :amount => a.amount}},
        :debits => self.amounts.debits.map{|a| {:account => a.account, :amount => a.amount}},
      }
    end

    def matches_spec?(spec)
      self.description == spec[:description] and self.amounts_match_spec?(spec)
    end

    def amounts_match_spec?(spec)
      to_check = [
            [self.amounts.credits.all, spec[:credits]],
            [self.amounts.debits.all, spec[:debits]]
          ]

      to_check.map do |amounts,amount_spec|
        a = amounts.map{|a| [a.account, a.amount]}
        s = amount_spec.map{|a| [a[:account], a[:amount]]}
        (a - s).empty? and (s - a).empty?
      end.all?
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
      balance = self.amounts.iterated_balance
      errors[:base] << "The credit and debit amounts are not equal" if balance.nil? or balance != 0
    end
  end
end
