module ESA
  module Filters
    module TimestampFilter
      extend ActiveSupport::Concern

      included do
        scope :created_before, lambda { |time| where(arel_table[:created_at].lt(time)) }
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::TimestampFilter
ESA::Event.send :include, ESA::Filters::TimestampFilter
ESA::Flag.send :include, ESA::Filters::TimestampFilter
ESA::Transaction.send :include, ESA::Filters::TimestampFilter
