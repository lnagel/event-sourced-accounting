module ESA
  module Contexts
    class DateContext < ESA::Context
      def initialize(date)
        date_filter = lambda { |scoped| scoped.with_date(date) }
        super([date_filter])
      end
    end
  end
end
