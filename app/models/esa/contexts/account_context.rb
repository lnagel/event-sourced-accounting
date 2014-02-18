module ESA
  module Contexts
    class AccountContext < ESA::Context
      attr_accessible :account, :account_id
      attr_readonly   :account, :account_id

      belongs_to :account

      validates_presence_of :account

      protected

      def create_name
        self.account.name unless self.account.nil?
      end

      def initialize_filters
        @filters = [lambda { |relation| relation.with_account(self.account_id) }]
      end
    end
  end
end

require 'esa/contexts/account_context_provider'
