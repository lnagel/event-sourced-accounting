module ESA
  module Contexts
    class AccountContext < ESA::Context
      def initialize(account)
        filter = lambda { |scoped| scoped.with_account(account) }
        super([filter])
      end
    end
  end
end
