module ESA
  module Contexts
    class EmptyContext < ESA::Context
      def effective_contexts
        [self]
      end

      protected

      def create_name
        "Empty"
      end

      def initialize_filters
        @filters = [lambda { |relation| relation.where('1=0') }]
      end
    end
  end
end
