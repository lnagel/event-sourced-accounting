module ESA
  module Contexts
    module AccountableTypeContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_accountable_types
          self.transactions.pluck(:accountable_type).uniq
        end

        def existing_accountable_type_subcontexts
          self.subcontexts.where(type: AccountableTypeContext).all
        end

        def contained_accountable_type_contexts
          existing_subcontexts = self.existing_accountable_type_subcontexts

          new_types = self.contained_accountable_types - existing_subcontexts.map{|tx| tx.accountable_type}.uniq

          new_subcontexts = new_types.map do |type|
            AccountableTypeContext.create(parent: self, accountable_type: type)
          end

          existing_subcontexts + new_subcontexts
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::AccountableTypeContextProvider
