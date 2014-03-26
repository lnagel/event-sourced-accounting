module ESA
  module Filters
    module AccountableFilter
      module TransactionAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable,type|
            if accountable.is_a? ActiveRecord::Relation then accountable = accountable.pluck("`#{accountable.table_name}`.`#{accountable.primary_key}`") end
            joins(:transaction).where(esa_transactions: {accountable_id: accountable, accountable_type: type})
          }
          scope :with_accountable_type, lambda { |type| joins(:transaction).where(esa_transactions: {accountable_type: type}) }
        end
      end

      module ObjectAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable,type|
            if accountable.is_a? ActiveRecord::Relation then accountable = accountable.pluck("`#{accountable.table_name}`.`#{accountable.primary_key}`") end
            where(accountable_id: accountable, accountable_type: type)
          }
          scope :with_accountable_type, lambda { |type| where(accountable_type: type) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::AccountableFilter::TransactionAccountable
ESA::Event.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
ESA::Flag.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
ESA::Transaction.send :include, ESA::Filters::AccountableFilter::ObjectAccountable
