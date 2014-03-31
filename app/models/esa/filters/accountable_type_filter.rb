module ESA
  module Filters
    module AccountableTypeFilter
      module TransactionAccountableType
        extend ActiveSupport::Concern

        included do
          scope :with_accountable_type, lambda { |type| joins(:transaction).where(esa_transactions: {accountable_type: type}) }
        end
      end

      module ObjectAccountableType
        extend ActiveSupport::Concern

        included do
          scope :with_accountable_type, lambda { |type| where(accountable_type: type) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::AccountableTypeFilter::TransactionAccountableType
ESA::Event.send :include, ESA::Filters::AccountableTypeFilter::ObjectAccountableType
ESA::Flag.send :include, ESA::Filters::AccountableTypeFilter::ObjectAccountableType
ESA::Transaction.send :include, ESA::Filters::AccountableTypeFilter::ObjectAccountableType
