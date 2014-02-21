module ESA
  module Contexts
    class OpenCloseContext < DateContext
      def effective_contexts
        self.parents_and_self.reject{|ctx| ctx.type == DateContext.to_s}
      end

      protected

      def validate_dates
        # OpenCloseContext can be initialized with no dates
      end
    end
  end
end
