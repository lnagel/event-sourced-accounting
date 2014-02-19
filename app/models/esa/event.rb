module ESA
  class Event < ActiveRecord::Base
    include Traits::Extendable
    extend ::Enumerize

    attr_accessible :time, :nature, :accountable, :ruleset
    attr_readonly   :time, :nature, :accountable, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :ruleset
    has_many   :flags
    has_many   :transactions, :through => :flags
    has_many   :amounts, :through => :transactions, :extend => Associations::AmountsExtension

    enumerize :nature, in: [:unknown]

    after_initialize :default_values
    validates_presence_of :time, :nature, :accountable, :ruleset
    validates_inclusion_of :processed, :in => [true, false]
    validate :validate_time

    after_create :enqueue_accountable

    def validate_time
      if self.new_record? and self.accountable.present?
        last_event_time = self.accountable.esa_events.maximum(:time)
        if last_event_time.present? and self.time < last_event_time
          errors[:time] = "Events can only be appended with a later time"
        end
      end
    end

    def produce_flags
      flags = self.flags.all
      if self.ruleset.present?
        required_flags = self.ruleset.event_flags_as_attributes(self)
        required_flags.map do |attrs|
          existing = flags.find{|f| f.nature == attrs[:nature].to_s and f.state == attrs[:state]}
          if existing.present?
            existing
          else
            flag = self.accountable.esa_flags.new(attrs)
            self.flags << flag
            flag
          end
        end
      else
        flags
      end
    end

    def create_flags
      if not self.processed and not self.processed_was
        self.produce_flags.map(&:save).all?
      else
        true
      end
    end

    def enqueue_accountable
      Config.processor.enqueue(self.accountable)
    end

    private

    def default_values
      self.time ||= Time.zone.now if self.time.nil?
      self.ruleset ||= Ruleset.extension_instance(self.accountable) if self.ruleset_id.nil? and not self.accountable_id.nil?
      self.processed ||= false
    end
  end
end
