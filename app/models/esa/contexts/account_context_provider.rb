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
          self.contained_account_ids.map do |id|
            ESA::Contexts::AccountContext.new(parent: self, account_id: id)
          end
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::AccountContextProvider
