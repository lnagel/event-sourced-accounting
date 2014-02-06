module ESA
  class Event < ActiveRecord::Base
    include Extendable

    attr_accessible :time, :event, :eventful, :ruleset

    belongs_to :eventful, :polymorphic => true
    belongs_to :ruleset, :class_name => 'ESA::Ruleset', :foreign_key => 'ruleset_id'
    has_many   :flags, :class_name => 'ESA::Flag', :foreign_key => 'event_id'

    #enums :event => { :unknown => 0 }

    validates_presence_of :time, :event, :eventful, :ruleset

    before_validation :check_attrs
    before_create :validate_time
    after_create :create_flags

    def check_attrs 
      self.time ||= Time.zone.now
      self.ruleset ||= Ruleset.extension_class(self).fetch
    end

    def validate_time
      last_event_time = eventful.events.maximum(:time)
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
        Flag.extension_class(self).produce_flags(self.eventful.flags, self, event_flags)
      else
        []
      end
    end

    def save_produced_flags
      flags = self.produce_flags
      flags.map(&:save).reduce(true){|a,b| a and b}
    end
  end
end