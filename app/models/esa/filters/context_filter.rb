module ESA
  module Filters
    module ContextFilter
      extend ActiveSupport::Concern

      included do
        scope :with_context, lambda { |*contexts|
          contexts.flatten.uniq.
          select{|ctx| ctx.respond_to? :apply}.
          inject(where([])) do |relation,context|
            context.apply(relation)
          end
        }
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::ContextFilter
ESA::Event.send :include, ESA::Filters::ContextFilter
ESA::Flag.send :include, ESA::Filters::ContextFilter
ESA::Transaction.send :include, ESA::Filters::ContextFilter
