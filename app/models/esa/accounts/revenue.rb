module ESA
  module Accounts
    # The Revenue class is an account type used to represents increases in owners equity.
    #
    # === Normal Balance
    # The normal balance on Revenue accounts is a *Credit*.
    #
    # @see http://en.wikipedia.org/wiki/Revenue Revenue
    #
    # @author Michael Bulat
    class Revenue < ESA::Account
      # The normal balance for the account. Must be overridden in implementations.
      def update_normal_balance
        unless self.contra
          self.normal_balance = :credit
        else
          self.normal_balance = :debit
        end
      end
    end
  end
end
