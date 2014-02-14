module ESA
  module Contexts
    class AccountContext < ESA::Context
      def initialize(account)
        filter = lambda { |relation| relation.with_account(account) }
        super([filter])
      end
    end
  end
end
