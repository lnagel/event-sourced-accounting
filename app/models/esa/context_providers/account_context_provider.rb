module ESA
  module ContextProviders
    class AccountContextProvider < ESA::ContextProvider
      def self.contained_account_ids(context)
        context.amounts.pluck(:account_id).uniq
      end

      def self.contained_subcontexts(context, namespace, existing, options = {})
        existing = existing.select{|sub| sub.type == "ESA::Contexts::AccountContext"}

        contained_ids = contained_account_ids(context)
        existing_ids = existing.map{|sub| sub.account_id}

        new_ids = contained_ids - existing_ids
        new_subcontexts = new_ids.map do |id|
          ESA::Contexts::AccountContext.new(parent: context, namespace: namespace, account_id: id)
        end

        new_subcontexts + existing.select{|sub| sub.account_id.in? contained_ids}
      end
    end
  end
end
