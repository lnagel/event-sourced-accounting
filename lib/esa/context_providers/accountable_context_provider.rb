module ESA
  module ContextProviders
    class AccountableContextProvider < ESA::ContextProvider
      def self.provided_types
        ["ESA::Contexts::AccountableContext"]
      end

      def self.context_id(context, options = {})
        [context.accountable_id, context.accountable_type]
      end

      def self.contained_ids(context, options = {})
        context.transactions.pluck([:accountable_id, :accountable_type]).uniq
      end

      def self.instantiate(parent, namespace, id, options = {})
        accountable_id, accountable_type = id
        ESA::Contexts::AccountableContext.new(chart_id: parent.chart_id, parent_id: parent.id, namespace: namespace, accountable_id: accountable_id, accountable_type: accountable_type)
      end
    end
  end
end
