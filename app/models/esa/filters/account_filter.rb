module ESA
  module Filters
    module AccountFilter
      module FlagTransactionAmountAccount
        extend ActiveSupport::Concern

        included do
          scope :with_account, lambda { |account| joins(:flags => {:transactions => :amounts}).where(esa_amounts: {account_id: account.id}) }
          scope :with_account_id, lambda { |id| joins(:flags => {:transactions => :amounts}).where(esa_amounts: {account_id: id}) }
        end
      end

      module TransactionAmountAccount
        extend ActiveSupport::Concern

        included do
          scope :with_account, lambda { |account| joins(:transactions => :amounts).where(esa_amounts: {account_id: account.id}) }
          scope :with_account_id, lambda { |id| joins(:transactions => :amounts).where(esa_amounts: {account_id: id}) }
        end
      end

      module AmountAccount
        extend ActiveSupport::Concern

        included do
          scope :with_account, lambda { |account| joins(:amounts).where(esa_amounts: {account_id: account.id}) }
          scope :with_account_id, lambda { |id| joins(:amounts).where(esa_amounts: {account_id: id}) }
        end
      end

      module ObjectAccount
        extend ActiveSupport::Concern

        included do
          scope :with_account, lambda { |account| where(account_id: account.id) }
          scope :with_account_id, lambda { |id| where(account_id: id) }
        end
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::AccountFilter::ObjectAccount
ESA::Event.send :include, ESA::Filters::AccountFilter::FlagTransactionAmountAccount
ESA::Flag.send :include, ESA::Filters::AccountFilter::TransactionAmountAccount
ESA::Transaction.send :include, ESA::Filters::AccountFilter::AmountAccount
