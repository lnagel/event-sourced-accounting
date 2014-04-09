module ESA
  module Filters
    module DateTimeFilter
      module DateScopes
        extend ActiveSupport::Concern

        included do
          scope :with_date_range, lambda { |range| with_time_range(range.begin.midnight..range.end.end_of_day) }
          scope :with_date_lt,    lambda { |date| with_time_lt(date.midnight) }
          scope :with_date_gt,    lambda { |date| with_time_gt(date.end_of_day) }
          scope :with_date_lte,   lambda { |date| with_time_lte(date.end_of_day) }
          scope :with_date_gte,   lambda { |date| with_time_gte(date.midnight) }
        end
      end

      module TransactionTime
        extend ActiveSupport::Concern
        include DateScopes

        included do
          scope :with_time_range, lambda { |range| joins(:transaction).where(esa_transactions: {time: range}) }
          scope :with_time_lt,    lambda { |time|  joins(:transaction).where(ESA::Transaction.arel_table[:time].lt(time)) }
          scope :with_time_gt,    lambda { |time|  joins(:transaction).where(ESA::Transaction.arel_table[:time].gt(time)) }
          scope :with_time_lte,   lambda { |time|  joins(:transaction).where(ESA::Transaction.arel_table[:time].lteq(time)) }
          scope :with_time_gte,   lambda { |time|  joins(:transaction).where(ESA::Transaction.arel_table[:time].gteq(time)) }
        end
      end

      module ObjectTime
        extend ActiveSupport::Concern
        include DateScopes

        included do
          scope :with_time_range, lambda { |range| where(time: range) }
          scope :with_time_lt,    lambda { |time|  where(arel_table[:time].lt(time)) }
          scope :with_time_gt,    lambda { |time|  where(arel_table[:time].gt(time)) }
          scope :with_time_lte,   lambda { |time|  where(arel_table[:time].lteq(time)) }
          scope :with_time_gte,   lambda { |time|  where(arel_table[:time].gteq(time)) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::DateTimeFilter::TransactionTime
ESA::Event.send :include, ESA::Filters::DateTimeFilter::ObjectTime
ESA::Flag.send :include, ESA::Filters::DateTimeFilter::ObjectTime
ESA::Transaction.send :include, ESA::Filters::DateTimeFilter::ObjectTime
