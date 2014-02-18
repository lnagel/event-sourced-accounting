module ESA
  module Filters
    module ContextFilter
      extend ActiveSupport::Concern

      included do
        scope :with_context, lambda { |*contexts|
          contexts.flatten.uniq.
          map do |ctx|
            if ctx.is_a? Integer or ctx.is_a? String
              ESA::Context.find(ctx.to_i) rescue nil
            else
              ctx
            end
          end.
          inject(where([])) do |relation,ctx|
            if not ctx.nil? and ctx.respond_to? :apply
              # good, the context can be applied directly
              ctx.apply(relation)
            else
              # context not found, or cannot be applied
              # either way, make sure we dont return results
              relation.where("1=0")
            end
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
