module ESA
  module Accountable
    extend ActiveSupport::Concern

    included do
      has_many :esa_events,       :as => :accountable, :class_name => ESA::Event.extension_name(self),       :extend => [ESA::Associations::EventsExtension, ESA::Associations::ContextExtension]
      has_many :esa_flags,        :as => :accountable, :class_name => ESA::Flag.extension_name(self),        :extend => [ESA::Associations::FlagsExtension, ESA::Associations::ContextExtension]
      has_many :esa_transactions, :as => :accountable, :class_name => ESA::Transaction.extension_name(self), :extend => [ESA::Associations::TransactionsExtension, ESA::Associations::ContextExtension]
    end
  end
end
