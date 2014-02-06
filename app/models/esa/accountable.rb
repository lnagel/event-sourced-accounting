module ESA
  module Accountable
    extend ActiveSupport::Concern

    included do
      has_many   :events, :as => :eventful, :class_name => ESA::Event.extension_name(self), :extend => ESA::Associations::EventsExtension
      has_many   :flags,  :as => :stateful, :class_name => ESA::Flag.extension_name(self), :extend => ESA::Associations::FlagsExtension
    end
  end
end
