module ESA
  module Amounts
    # The Credit class represents credit entries in the transaction journal.
    #
    # @example
    #     credit_amount = ESA::Amounts::Credit.new(:account => revenue, :amount => 1000)
    #
    # @author Michael Bulat
    class Credit < ESA::Amount
    end
  end
end