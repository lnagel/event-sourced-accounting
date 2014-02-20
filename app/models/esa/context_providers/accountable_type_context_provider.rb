module ESA
  module ContextProviders
    class AccountableTypeContextProvider < ESA::ContextProvider
      def self.contained_accountable_types(context)
        context.transactions.pluck(:accountable_type).uniq
      end

      def self.contained_subcontexts(context, namespace, existing, options = {})
        contained_types = contained_accountable_types(context)
        existing_types = existing.map{|sub| sub.accountable_type}

        new_types = contained_types - existing_types
        new_types = new_types & options[:whitelist] if options[:whitelist].present?
        new_types = new_types - options[:blacklist] if options[:blacklist].present?

        new_subcontexts = new_types.map do |type|
          ESA::Contexts::AccountableTypeContext.new(parent: context, namespace: namespace, accountable_type: type)
        end

        new_subcontexts + existing.select{|sub| sub.accountable_type.in? contained_types}
      end
    end
  end
end
