module ESA
  module Contexts
    class AccountContext < ESA::Context
      attr_accessible :account

      protected

      def default_values
        @filters = [lambda { |relation| relation.with_account(self.account) }]
      end
    end
  end
end
