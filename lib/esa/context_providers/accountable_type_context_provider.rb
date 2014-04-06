module ESA
  module ContextProviders
    class AccountableTypeContextProvider < ESA::ContextProvider
      def self.provided_types
        ["ESA::Contexts::AccountableTypeContext"]
      end

      def self.context_id(context, options = {})
        context.accountable_type
      end

      def self.contained_ids(context, options = {})
        context.transactions.pluck(:accountable_type).uniq
      end

      def self.instantiate(parent, namespace, id, options = {})
        ESA::Contexts::AccountableTypeContext.new(chart_id: parent.chart_id, parent_id: parent.id, namespace: namespace, accountable_type: id)
      end
    end
  end
end
