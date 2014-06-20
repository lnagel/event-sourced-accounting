module ESA
  module ContextProviders
    class AccountContextProvider < ESA::ContextProvider
      def self.provided_types
        ["ESA::Contexts::AccountContext"]
      end

      def self.context_id(context, options = {})
        context.account_id
      end

      def self.contained_ids(context, options = {})
        if options[:all].present? and options[:all] == true
          context.accounts.pluck(:id)
        else
          context.amounts.uniq.pluck(:account_id)
        end
      end

      def self.instantiate(parent, namespace, id, options = {})
        ESA::Contexts::AccountContext.new(chart_id: parent.chart_id, parent_id: parent.id, namespace: namespace, account_id: id)
      end
    end
  end
end
