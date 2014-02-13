module ESA
  module Filters
    module DateFilter
      module TransactionDate
        extend ActiveSupport::Concern

        included do
          scope :between_dates, lambda { |date1,date2| joins(:transaction).where(esa_transactions: {time: date1.midnight..date2.end_of_day}) }
          scope :with_date,     lambda { |date| joins(:transaction).where(esa_transactions: {time: date.midnight..date.end_of_day}) }
          scope :with_date_lt,  lambda { |date| joins(:transaction).where(ESA::Transaction.arel_table[:time].lt( date.midnight)) }
          scope :with_date_gt,  lambda { |date| joins(:transaction).where(ESA::Transaction.arel_table[:time].gt( date.end_of_day)) }
          scope :with_date_lte, lambda { |date| joins(:transaction).where(ESA::Transaction.arel_table[:time].lteq(date.end_of_day)) }
          scope :with_date_gte, lambda { |date| joins(:transaction).where(ESA::Transaction.arel_table[:time].gteq(date.midnight)) }
        end
      end

      module ObjectDate
        extend ActiveSupport::Concern

        included do
          scope :between_dates, lambda { |date1,date2| where(time: date1.midnight..date2.end_of_day) }
          scope :with_date,     lambda { |date| where(time: date.midnight..date.end_of_day) }
          scope :with_date_lt,  lambda { |date| where(arel_table[:time].lt( date.midnight)) }
          scope :with_date_gt,  lambda { |date| where(arel_table[:time].gt( date.end_of_day)) }
          scope :with_date_lte, lambda { |date| where(arel_table[:time].lteq(date.end_of_day)) }
          scope :with_date_gte, lambda { |date| where(arel_table[:time].gteq(date.midnight)) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::DateFilter::TransactionDate
ESA::Event.send :include, ESA::Filters::DateFilter::ObjectDate
ESA::Flag.send :include, ESA::Filters::DateFilter::ObjectDate
ESA::Transaction.send :include, ESA::Filters::DateFilter::ObjectDate
