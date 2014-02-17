module ESA
  module Contexts
    module AccountContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_account_ids
          self.amounts.pluck(:account_id).uniq
        end

        def contained_accounts
          ESA::Account.find(self.contained_account_ids)
        end

        def contained_account_contexts
          self.contained_accounts.map do |account|
            AccountContext.new(parent: self, account: account)
          end
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::AccountContextProvider
