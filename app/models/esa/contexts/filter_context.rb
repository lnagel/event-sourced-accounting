module ESA
  module Contexts
    class FilterContext < ESA::Context
      attr_accessor :filters

      def can_be_persisted?
        false
      end
    end
  end
end
