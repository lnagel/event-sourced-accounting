module ESA
  module Contexts
    module DateContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_dates
          self.transactions.pluck('date(time)').uniq
        end

        def contained_date_contexts
          self.contained_dates.map do |date|
            DateContext.new(parent: self, start_date: date, end_date: date)
          end
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::DateContextProvider
