module ESA
  module Contexts
    module AccountableContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_accountable_ids_types
          self.transactions.pluck([:accountable_id, :accountable_type]).uniq
        end

        def existing_accountable_subcontexts
          self.subcontexts.where(type: ESA::Contexts::AccountableContext).all
        end

        def contained_accountable_contexts
          existing_subcontexts = self.existing_accountable_subcontexts

          new_ids_types = self.contained_accountable_ids_types - existing_subcontexts.map{|tx| [tx.accountable_id, tx.accountable_type]}.uniq

          new_subcontexts = new_ids_types.map do |id,type|
            ESA::Contexts::AccountableContext.create(parent: self, accountable_id: id, accountable_type: type)
          end

          existing_subcontexts + new_subcontexts
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::AccountableContextProvider
