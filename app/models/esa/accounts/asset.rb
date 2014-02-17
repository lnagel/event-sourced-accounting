module ESA
  module Accounts
    # The Asset class is an account type used to represents resources owned by the business entity.
    #
    # === Normal Balance
    # The normal balance on Asset accounts is a *Debit*.
    #
    # @see http://en.wikipedia.org/wiki/Asset Assets
    #
    # @author Michael Bulat
    class Asset < ESA::Account

      # This class method is used to return
      # the balance of all Asset accounts.
      #
      # Contra accounts are automatically subtracted from the balance.
      #
      # @example
      #   >> ESA::Accounts::Asset.balance
      #   => #<BigDecimal:1030fcc98,'0.82875E5',8(20)>
      #
      # @return [BigDecimal] The decimal value balance
      def self.balance
        accounts_balance = BigDecimal.new('0')
        accounts = self.find(:all)
        accounts.each do |asset|
          unless asset.contra
            accounts_balance += asset.balance
          else
            accounts_balance -= asset.balance
          end
        end
        accounts_balance
      end

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
