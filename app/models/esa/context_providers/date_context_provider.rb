module ESA
  module ContextProviders
    class DateContextProvider < ESA::ContextProvider
      def self.contained_pairs(context, options = {})
        dates = context.transactions.pluck("date(esa_transactions.time)").uniq
        dates.zip dates
      end

      def self.contained_subcontexts(context, namespace, existing, options = {})
        contained_pairs = contained_pairs(context, options)
        existing_pairs = existing.map{|sub| [sub.start_date, sub.end_date]}

        new_pairs = contained_pairs - existing_pairs
        new_subcontexts = new_pairs.map do |start_date,end_date|
          ESA::Contexts::DateContext.new(parent: context, namespace: namespace, start_date: start_date, end_date: end_date)
        end

        new_subcontexts + existing.select{|sub| sub.date.in? contained_pairs}
      end
    end
  end
end
