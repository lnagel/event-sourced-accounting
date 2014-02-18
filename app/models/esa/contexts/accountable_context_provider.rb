module ESA
  module Contexts
    module AccountableContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_accountable_ids_types
          self.transactions.pluck([:accountable_id, :accountable_type]).uniq
        end

        def contained_accountable_types
          self.transactions.pluck(:accountable_type).uniq
        end

        def contained_accountable_contexts
          self.contained_accountable_ids_types.map do |id,type|
            AccountableContext.new(parent: self, accountable_id: id, accountable_type: type)
          end
        end

        def contained_accountable_type_contexts
          self.contained_accountable_types.map do |type|
            AccountableContext.new(parent: self, accountable_type: type)
          end
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::AccountableContextProvider
