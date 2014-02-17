module ESA
  # The Amount class represents debit and credit amounts in the system.
  #
  # @abstract
  #   An amount must be a subclass as either a debit or a credit to be saved to the database. 
  #
  # @author Michael Bulat
  class Amount < ActiveRecord::Base
    attr_accessible :account, :amount, :transaction

    belongs_to :transaction
    belongs_to :account

    validates_presence_of :type, :amount, :transaction, :account

    scope :credits, lambda { where(type: ESA::Amounts::Credit) }
    scope :debits, lambda { where(type: ESA::Amounts::Debit) }

    def is_credit?
      self.is_a? Amounts::Credit
    end

    def is_debit?
      self.is_a? Amounts::Debit
    end
  end
end
