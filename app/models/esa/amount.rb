module ESA
  # The Amount class represents debit and credit amounts in the system.
  #
  # @abstract
  #   An amount must be a subclass as either a debit or a credit to be saved to the database. 
  #
  # @author Lenno Nagel, Michael Bulat
  class Amount < ActiveRecord::Base
    attr_accessible :type, :account, :amount, :transaction

    belongs_to :transaction
    belongs_to :account

    validates_presence_of :type, :amount, :transaction, :account

    scope :credits, lambda { where(type: Amounts::Credit) }
    scope :debits, lambda { where(type: Amounts::Debit) }

    def is_credit?
      self.is_a? Amounts::Credit
    end

    def is_debit?
      self.is_a? Amounts::Debit
    end
  end
end
