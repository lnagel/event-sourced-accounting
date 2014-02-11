module ESA
  module Filters
    module DateFilter
      module TransactionDate
        extend ActiveSupport::Concern

        included do
          scope :with_date, lambda { |date| joins(:transaction).where(esa_transactions: {time: date.midnight..date.end_of_day}) }
        end
      end

      module ObjectDate
        extend ActiveSupport::Concern

        included do
          scope :with_date, lambda { |date| where(time: date.midnight..date.end_of_day) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::DateFilter::TransactionDate
ESA::Event.send :include, ESA::Filters::DateFilter::ObjectDate
ESA::Flag.send :include, ESA::Filters::DateFilter::ObjectDate
ESA::Transaction.send :include, ESA::Filters::DateFilter::ObjectDate
