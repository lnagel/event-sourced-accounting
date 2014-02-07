module ESA
  class Event < ActiveRecord::Base
    include Extendable
    extend ::Enumerize

    attr_accessible :time, :nature, :accountable, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :ruleset
    has_many   :flags
    has_many   :transactions, :through => :flags

    enumerize :nature, in: [:unknown]

    validates_presence_of :time, :nature, :accountable, :ruleset

    after_initialize :default_values

    before_create :validate_time
    after_create :create_flags

    def validate_time
      last_event_time = accountable.esa_events.maximum(:time)
      last_event_time.nil? or last_event_time <= time
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
      self.ruleset ||= Ruleset.extension_class(self).first_or_create
    end
  end
end