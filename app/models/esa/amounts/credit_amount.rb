module ESA
  module Amounts
    # The CreditAmount class represents credit entries in the transaction journal.
    #
    # @example
    #     credit_amount = ESA::CreditAmount.new(:account => revenue, :amount => 1000)
    #
    # @author Michael Bulat
    class CreditAmount < ESA::Amount
    end
  end
end