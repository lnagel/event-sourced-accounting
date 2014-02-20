module ESA
  module ContextProviders
    class AccountableContextProvider < ESA::ContextProvider
      def self.contained_accountable_ids(context)
        context.transactions.pluck([:accountable_id, :accountable_type]).uniq
      end

      def self.contained_subcontexts(context, namespace, existing, options = {})
        existing = existing.select{|sub| sub.type == "ESA::Contexts::AccountableContext"}

        contained_ids = contained_accountable_ids(context)
        existing_ids = existing.map{|sub| [sub.accountable_id, sub.accountable_type]}

        new_ids = contained_ids - existing_ids
        new_subcontexts = new_ids.map do |id,type|
          ESA::Contexts::AccountableContext.new(parent: context, namespace: namespace, accountable_id: id, accountable_type: type)
        end

        new_subcontexts + existing.select{|sub| [sub.accountable_id, sub.accountable_type].in? contained_ids}
      end
    end
  end
end
