module ESA
  module Contexts
    class AccountContext < ESA::Context
      attr_accessible :account_id
      attr_readonly   :account_id

      belongs_to :account

      validates_presence_of :account_id

      protected

      def initialize_filters
        @filters = [lambda { |relation| relation.with_account(self.account_id) }]
      end
    end
  end
end

require 'esa/contexts/account_context_provider'
