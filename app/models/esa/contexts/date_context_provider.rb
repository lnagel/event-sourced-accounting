module ESA
  module Contexts
    module DateContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_dates
          self.transactions.pluck("date(esa_transactions.time)").uniq
        end

        def existing_date_subcontexts
          self.subcontexts.where(type: DateContext).
          where("esa_contexts.start_date is not null and esa_contexts.end_date is not null").
          where("esa_contexts.start_date = esa_contexts.end_date").
          all
        end

        def contained_date_contexts
          existing_subcontexts = self.existing_date_subcontexts

          new_dates = self.contained_dates - existing_subcontexts.map(&:start_date).uniq

          new_subcontexts = new_dates.map do |date|
            DateContext.create(parent: self, start_date: date, end_date: date)
          end

          existing_subcontexts + new_subcontexts
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::DateContextProvider
