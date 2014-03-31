module ESA
  module ContextProviders
    class AccountContextProvider < ESA::ContextProvider
      def self.provided_types
        ["ESA::Contexts::AccountContext"]
      end

      def self.contained_account_ids(context)
        context.amounts.pluck(:account_id).uniq
      end

      def self.contained_subcontexts(context, namespace, existing, options = {})
        contained_ids = contained_account_ids(context)
        existing_ids = existing.map{|sub| sub.account_id}

        new_ids = contained_ids - existing_ids
        new_subcontexts = new_ids.map do |id|
          ESA::Contexts::AccountContext.new(chart_id: context.chart_id, parent_id: context.id, namespace: namespace, account_id: id)
        end

        new_subcontexts + existing.select{|sub| sub.account_id.in? contained_ids}
      end

      def self.affected_root_contexts(context)
        contained_ids = contained_account_ids(context)
        ESA::Contexts::AccountContext.roots.where(account_id: contained_ids)
      end
    end
  end
end
