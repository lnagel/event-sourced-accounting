module ESA
  module Filters
    module AccountableFilter
      module TransactionAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable| joins(:transaction).where(esa_transactions: {accountable_id: accountable}) }
        end
      end

      module ObjectAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable| where(accountable_id: accountable) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::AccountableFilter::TransactionAccountable
ESA::Event.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
ESA::Flag.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
ESA::Transaction.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
