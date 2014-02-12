module ESA
  module Filters
    module AccountableFilter
      module TransactionAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable| joins(:transaction).where(esa_transactions: {accountable_id: accountable.id}) }
          scope :with_accountable_id, lambda { |id| joins(:transaction).where(esa_transactions: {accountable_id: id}) }
        end
      end

      module ObjectAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable| where(accountable_id: accountable.id) }
          scope :with_accountable_id, lambda { |id| where(accountable_id: id) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::AccountableFilter::TransactionAccountable
ESA::Event.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
ESA::Flag.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
ESA::Transaction.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
