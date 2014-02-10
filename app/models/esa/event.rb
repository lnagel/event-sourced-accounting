module ESA
  class Event < ActiveRecord::Base
    include Extendable
    extend ::Enumerize

    attr_accessible :time, :nature, :accountable, :ruleset
    attr_readonly   :time, :nature, :accountable, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :ruleset
    has_many   :flags
    has_many   :transactions, :through => :flags

    enumerize :nature, in: [:unknown]

    after_initialize :default_values
    validates_presence_of :time, :nature, :accountable, :ruleset
    validate :validate_time

    after_create :create_flags

    def validate_time
      if self.new_record? and self.accountable.present?
        last_event_time = self.accountable.esa_events.maximum(:time)
        if last_event_time.present? and self.time < last_event_time
          errors[:time] = "Events can only be appended with a later time"
        end
      end
    end

    def create_flags
      if Settings.accounting[:create_flags]
        self.save_produced_flags
      end
    end

    # the base event has no flags
    # this must be overridden to produce useful results
    def produce_flags
      if self.ruleset.present?
        event_flags = self.ruleset.event_flags(self)
        Flag.extension_class(self).produce_flags(self.accountable.flags, self, event_flags)
      else
        []
      end
    end

    def save_produced_flags
      flags = self.produce_flags
      flags.map(&:save).reduce(true){|a,b| a and b}
    end

    private

    def default_values
      self.time ||= Time.zone.now
      self.ruleset ||= Ruleset.extension_instance(self)
    end
  end
end