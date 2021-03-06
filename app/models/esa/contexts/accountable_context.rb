module ESA
  module Contexts
    class AccountableContext < ESA::Context
      attr_accessible :accountable, :accountable_id, :accountable_type
      attr_readonly   :accountable, :accountable_id, :accountable_type

      belongs_to :accountable, :polymorphic => true

      validates_presence_of :accountable

      protected

      def default_name
        "#{self.accountable_type} #{self.accountable_id}" unless self.accountable_type.nil?
      end

      def initialize_filters
        @filters = []

        if self.accountable_id.present? and self.accountable_type.present?
          @filters << lambda { |relation| relation.with_accountable(self.accountable_id, self.accountable_type) }
        end
      end
    end
  end
end
