module ESA
  class Flag < ActiveRecord::Base
    include Extendable
    extend ::Enumerize

    attr_accessible :nature, :state, :event, :time, :accountable, :type, :ruleset
    attr_readonly   :nature, :state, :event, :time, :accountable, :type, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :event
    belongs_to :ruleset
    has_many   :transactions

    enumerize :nature, in: [:unknown]

    after_initialize :default_values
    validates_presence_of :nature, :event, :time, :accountable, :ruleset
    validates_inclusion_of :state, :in => [true, false]
    validates_inclusion_of :processed, :in => [true, false]
    validate :validate_transition

    after_create :record_transition, :create_transactions

    def is_set?
      self.state == true
    end

    def is_unset?
      self.state == false
    end

    def became_set?
      self.transition == 1
    end

    def became_unset?
      self.transition == -1
    end

    def produce_transactions
      if self.ruleset.present? and self.transition.present?
        transactions = self.ruleset.flag_transactions_as_attributes(self)
        transactions.map do |attrs|
          self.accountable.esa_transactions.new(attrs)
        end
      else
        []
      end
    end

    def create_transactions
      if not self.changed? and not self.processed and self.transition.present?
        self.processed = self.produce_transactions.map(&:save).all?
        self.save if self.changed?
      end
      true # do not block the save call
    end

    private

    def validate_transition
      if self.processed and not self.transition.in? [-1, 0, 1]
        errors[:processed] = "The transition must be in? [-1, 0, 1] before processed can be set to true"
      end
    end

    def record_transition
      if not self.accountable.nil? and not self.nature.nil? and not self.state.nil? and not self.time.nil?
        self.transition = event.accountable.esa_flags.transition_for(self)
        self.save if self.changed?
      end
    end

    def default_values
      if not self.event.nil?
        self.event ||= event
        self.time ||= event.time
        self.accountable ||= event.accountable
        self.ruleset ||= event.ruleset
      end

      self.processed ||= false
    end
  end
end
