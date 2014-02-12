module ESA
  module Filters
    module ContextFilter
      extend ActiveSupport::Concern

      included do
        scope :with_context, lambda { |context| context.apply(self) }
        scope :with_contexts, lambda { |contexts| contexts.inject(self){|relation,context| context.apply(relation)}}
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::ContextFilter
ESA::Event.send :include, ESA::Filters::ContextFilter
ESA::Flag.send :include, ESA::Filters::ContextFilter
ESA::Transaction.send :include, ESA::Filters::ContextFilter
