module ESA
  module Filters
    module AccountableFilter
      def self.make_union_query(definitions = {})
        fragments = definitions.map do |type,accountable|
          make_fragments(type, accountable)
        end.flatten

        if fragments.count > 0
          fragments.join(' UNION ')
        else
          "SELECT -1 AS id, 'Nothing' AS type"
        end
      end

      def self.make_fragments(type, accountable)
        if accountable.is_a? ActiveRecord::Relation
          [accountable.select("`#{accountable.table_name}`.`#{accountable.primary_key}` AS id, '#{type}' AS type").to_sql.squish]
        elsif accountable.is_a? ActiveRecord::Base
          ["SELECT #{accountable.id} AS id, '#{type}' AS type"]
        elsif accountable.is_a? Integer
          ["SELECT #{accountable} AS id, '#{type}' AS type"]
        elsif accountable.respond_to? :each
          accountable.map{|a| make_fragments(type, a)}.flatten
        else
          []
        end
      end

      module TransactionAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable,type|
            joins(:transaction).where(esa_transactions: {accountable_id: accountable, accountable_type: type})
          }
          scope :with_accountable_def, lambda { |definitions| joins(:transaction).joins("INNER JOIN (#{ESA::Filters::AccountableFilter.make_union_query(definitions)}) `accountables-#{(hash ^ definitions.hash).to_s(36)}` ON `esa_transactions`.`accountable_id` = `accountables-#{(hash ^ definitions.hash).to_s(36)}`.`id` AND `esa_transactions`.`accountable_type` = `accountables-#{(hash ^ definitions.hash).to_s(36)}`.`type`") }
          scope :with_accountable_type, lambda { |type| joins(:transaction).where(esa_transactions: {accountable_type: type}) }
        end
      end

      module ObjectAccountable
        extend ActiveSupport::Concern

        included do
          scope :with_accountable, lambda { |accountable,type|
            where(accountable_id: accountable, accountable_type: type)
          }
          scope :with_accountable_def, lambda { |definitions| joins("INNER JOIN (#{ESA::Filters::AccountableFilter.make_union_query(definitions)}) `accountables-#{(hash ^ definitions.hash).to_s(36)}` ON `#{table_name}`.`accountable_id` = `accountables-#{(hash ^ definitions.hash).to_s(36)}`.`id` AND `#{table_name}`.`accountable_type` = `accountables-#{(hash ^ definitions.hash).to_s(36)}`.`type`") }
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
