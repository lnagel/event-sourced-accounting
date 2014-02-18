module ESA
  module Contexts
    class AccountableTypeContext < ESA::Context
      attr_accessible :accountable_type
      attr_readonly   :accountable_type

      validates_presence_of :accountable_type

      protected

      def create_name
        "#{self.accountable_type} accountables" unless self.accountable_type.nil?
      end

      def initialize_filters
        @filters = []

        if self.accountable_type.present?
          @filters << lambda { |relation| relation.with_accountable_type(self.accountable_type) }
        end
      end
    end
  end
end

require 'esa/contexts/accountable_type_context_provider'
