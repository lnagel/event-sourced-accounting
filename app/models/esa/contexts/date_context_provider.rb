module ESA
  module Contexts
    module DateContextProvider
      extend ActiveSupport::Concern

      included do
        def contained_dates
          self.transactions.pluck('date(time)').uniq
        end

        def contained_date_contexts
          contained_dates = self.contained_dates

          date_subcontexts = self.subcontexts.where(type: DateContext).all

          subcontext_dates = date_subcontexts.select do |ctx|
            ctx.start_date.present? and ctx.end_date.present? and ctx.start_date = ctx.end_date
          end.map do |ctx|
            ctx.start_date
          end.uniq

          remaining_dates = contained_dates - subcontext_dates

          new_subcontexts = remaining_dates.map do |date|
            DateContext.new(parent: self, start_date: date, end_date: date)
          end

          date_subcontexts + new_subcontexts
        end

        def create_date_contexts
          self.contained_date_contexts.map do |ctx|
            if ctx.new_record?
              ctx.save
            else
              true
            end
          end.all?
        end
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::DateContextProvider
