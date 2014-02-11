module ESA
  module Filters
    module TransactionDate
      module AmountConcern
        extend ActiveSupport::Concern

        included do
          scope :with_date, lambda { |date| joins(:transaction).where(esa_transactions: {time: date.midnight..date.end_of_day}) }
        end
      end

      module TransactionConcern
        extend ActiveSupport::Concern

        included do
          scope :with_date, lambda { |date| where(time: date.midnight..date.end_of_day) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::TransactionDate::AmountConcern
ESA::Transaction.send :include, ESA::Filters::TransactionDate::TransactionConcern
