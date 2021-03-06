module ESA
  module Accounts
    # The Asset class is an account type used to represents resources owned by the business entity.
    #
    # === Normal Balance
    # The normal balance on Asset accounts is a *Debit*.
    #
    # @see http://en.wikipedia.org/wiki/Asset Assets
    #
    # @author Lenno Nagel
    class Asset < ESA::Account
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
