module ESA
  module Accounts
    # The Liability class is an account type used to represents debts owed to outsiders.
    #
    # === Normal Balance
    # The normal balance on Liability accounts is a *Credit*.
    #
    # @see http://en.wikipedia.org/wiki/Liability_(financial_accounting) Liability
    #
    # @author Lenno Nagel
    class Liability < ESA::Account
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
