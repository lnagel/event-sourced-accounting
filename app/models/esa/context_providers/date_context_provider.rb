module ESA
  module ContextProviders
    class DateContextProvider < ESA::ContextProvider
      def self.provided_types
        ["ESA::Contexts::DateContext"]
      end

      def self.context_id(context, options = {})
        [context.start_date, context.end_date]
      end

      def self.contained_ids(context, options = {})
        dates = context.transactions.pluck("date(esa_transactions.time)").uniq.sort

        if options[:period].present? and options[:period] == :month
          dates.group_by{|d| [d.year, d.month]}.keys.
          map do |year,month|
            start_date = Date.new(year, month, 1)
            end_date = start_date.end_of_month
            [start_date, end_date]
          end
        else
          dates.zip dates
        end
      end

      def self.instantiate(parent, namespace, id, options = {})
        start_date, end_date = id
        ESA::Contexts::DateContext.new(chart_id: parent.chart_id, parent_id: parent.id, namespace: namespace, start_date: start_date, end_date: end_date)
      end
    end
  end
end
