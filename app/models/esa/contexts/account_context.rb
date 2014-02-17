module ESA
  module Contexts
    class AccountContext < ESA::Context
      attr_accessible :account
      attr_readonly   :account

      belongs_to :account

      validates_presence_of :account

      protected

      def initialize_filters
        @filters = [lambda { |relation| relation.with_account(self.account) }]
      end
    end
  end
end

ESA::Context.send :include, ESA::Contexts::AccountContextProvider
