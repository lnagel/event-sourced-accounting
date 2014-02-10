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
    validates_inclusion_of :processed, :in => [true, false]
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

    def produce_flags
      if self.ruleset.present?
        flags = self.ruleset.event_flags_as_attributes(self)
        flags.map do |attrs|
          self.accountable.esa_flags.new(attrs)
        end
      else
        []
      end
    end

    def create_flags
      if not self.changed? and not self.processed
        self.processed = self.produce_flags.map(&:save).all?
        self.save if self.changed?
      end
      true # do not block the save call
    end

    private

    def default_values
      self.time ||= Time.zone.now
      self.ruleset ||= Ruleset.extension_instance(self)
      self.processed ||= false
    end
  end
end
