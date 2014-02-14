module ESA
  module Contexts
    class DateContext < ESA::Context
      def initialize(date)
        filter = lambda { |relation| relation.with_date(date) }
        super([filter])
      end
    end
  end
end
