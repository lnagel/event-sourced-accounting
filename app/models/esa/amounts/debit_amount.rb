module ESA
  module Amounts
    # The DebitAmount class represents debit entries in the transaction journal.
    #
    # @example
    #     debit_amount = ESA::DebitAmount.new(:account => cash, :amount => 1000)
    #
    # @author Michael Bulat
    class DebitAmount < ESA::Amount
    end
  end
end