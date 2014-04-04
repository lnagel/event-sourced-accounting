module ESA
  module Accounts
    # The Expense class is an account type used to represents assets or services consumed in the generation of revenue.
    #
    # === Normal Balance
    # The normal balance on Expense accounts is a *Debit*.
    #
    # @see http://en.wikipedia.org/wiki/Expense Expenses
    #
    # @author Lenno Nagel
    class Expense < ESA::Account
      # The normal balance for the account. Must be overridden in implementations.
      def update_normal_balance
        unless self.contra
          self.normal_balance = :debit
        else
          self.normal_balance = :credit
        end
      end
    end
  end
end
