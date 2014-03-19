module ESA
  module Traits
    module Accountable
      extend ActiveSupport::Concern

      included do
        has_many :esa_events,       :as => :accountable, :class_name => ESA::Event.extension_name(self),       :extend => ESA::Associations::EventsExtension
        has_many :esa_flags,        :as => :accountable, :class_name => ESA::Flag.extension_name(self),        :extend => ESA::Associations::FlagsExtension
        has_many :esa_transactions, :as => :accountable, :class_name => ESA::Transaction.extension_name(self), :extend => ESA::Associations::TransactionsExtension

        def esa_ruleset
          ESA::Ruleset.extension_instance(self)
        end

        def esa_chart
          self.esa_ruleset.chart
        end

        def create_esa_events
          self.esa_ruleset.create_unrecorded_events(self)
        end

        def create_esa_events!
          self.esa_ruleset.create_unrecorded_events!(self)
        end
      end
    end
  end
end
