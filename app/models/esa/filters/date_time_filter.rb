module ESA
  module Filters
    module DateTimeFilter
      module TransactionDate
        extend ActiveSupport::Concern

        included do
          scope :between_dates, lambda { |date1,date2| joins(:transaction).where(esa_transactions: {time: date1.midnight..date2.end_of_day}) }
          scope :with_date,     lambda { |date| joins(:transaction).where(esa_transactions: {time: date.midnight..date.end_of_day}) }

          scope :with_date_lt,  lambda { |date| with_time_lt(date.midnight) }
          scope :with_date_gt,  lambda { |date| with_time_gt(date.end_of_day) }
          scope :with_date_lte, lambda { |date| with_time_lte(date.end_of_day) }
          scope :with_date_gte, lambda { |date| with_time_gte(date.midnight) }

          scope :with_time_lt,  lambda { |time| joins(:transaction).where(ESA::Transaction.arel_table[:time].lt( time)) }
          scope :with_time_gt,  lambda { |time| joins(:transaction).where(ESA::Transaction.arel_table[:time].gt( time)) }
          scope :with_time_lte, lambda { |time| joins(:transaction).where(ESA::Transaction.arel_table[:time].lteq(time)) }
          scope :with_time_gte, lambda { |time| joins(:transaction).where(ESA::Transaction.arel_table[:time].gteq(time)) }
        end
      end

      module ObjectDate
        extend ActiveSupport::Concern

        included do
          scope :between_dates, lambda { |date1,date2| where(time: date1.midnight..date2.end_of_day) }
          scope :with_date,     lambda { |date| where(time: date.midnight..date.end_of_day) }

          scope :with_date_lt,  lambda { |date| with_time_lt(date.midnight) }
          scope :with_date_gt,  lambda { |date| with_time_gt(date.end_of_day) }
          scope :with_date_lte, lambda { |date| with_time_lte(date.end_of_day) }
          scope :with_date_gte, lambda { |date| with_time_gte(date.midnight) }

          scope :with_time_lt,  lambda { |time| where(arel_table[:time].lt( time)) }
          scope :with_time_gt,  lambda { |time| where(arel_table[:time].gt( time)) }
          scope :with_time_lte, lambda { |time| where(arel_table[:time].lteq(time)) }
          scope :with_time_gte, lambda { |time| where(arel_table[:time].gteq(time)) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::DateTimeFilter::TransactionDate
ESA::Event.send :include, ESA::Filters::DateTimeFilter::ObjectDate
ESA::Flag.send :include, ESA::Filters::DateTimeFilter::ObjectDate
ESA::Transaction.send :include, ESA::Filters::DateTimeFilter::ObjectDate
