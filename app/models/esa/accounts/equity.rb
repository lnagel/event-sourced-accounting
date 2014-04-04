module ESA
  module Accounts
    # The Equity class is an account type used to represents owners rights to the assets.
    #
    # === Normal Balance
    # The normal balance on Equity accounts is a *Credit*.
    #
    # @see http://en.wikipedia.org/wiki/Equity_(finance) Equity
    #
    # @author Lenno Nagel
    class Equity < ESA::Account
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
