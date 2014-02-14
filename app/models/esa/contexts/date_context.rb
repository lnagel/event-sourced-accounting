module ESA
  module Contexts
    class DateContext < ESA::Context
      attr_accessible :date

      protected

      def default_values
        @filters = [lambda { |relation| relation.with_date(self.date) }]
      end
    end
  end
end
