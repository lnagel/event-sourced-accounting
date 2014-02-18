module ESA
  module Contexts
    module AccountableTypeContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_accountable_types
          self.transactions.pluck(:accountable_type).uniq
        end

        def existing_accountable_type_subcontexts
          self.subcontexts.where(type: ESA::Contexts::AccountableTypeContext).all
        end

        def contained_accountable_type_contexts(options = {})
          existing_subcontexts = self.existing_accountable_type_subcontexts

          new_types = self.contained_accountable_types - existing_subcontexts.map{|tx| tx.accountable_type}.uniq
          new_types = new_types & options[:whitelist] if options[:whitelist].present?
          new_types = new_types - options[:blacklist] if options[:blacklist].present?

          new_subcontexts = new_types.map do |type|
            ESA::Contexts::AccountableTypeContext.create(parent: self, accountable_type: type)
          end

          existing_subcontexts + new_subcontexts
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::AccountableTypeContextProvider
