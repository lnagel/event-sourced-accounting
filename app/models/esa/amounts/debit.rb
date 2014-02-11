module ESA
  module Amounts
    # The Debit class represents debit entries in the transaction journal.
    #
    # @example
    #     debit_amount = ESA::Amounts::Debit.new(:account => cash, :amount => 1000)
    #
    # @author Michael Bulat
    class Debit < ESA::Amount
    end
  end
end