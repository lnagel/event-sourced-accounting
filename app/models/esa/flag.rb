require 'esa/associations/amounts_extension'
require 'esa/traits/extendable'

module ESA
  # The Flag class represents a change of known state of an Accountable
  # and it is used record differences of state caused by Events.
  # 
  # A Flag with an UP transition creates normal Transactions according to
  # the rules specified in a Ruleset. Flags with a DOWN transition revert
  # Transactions created earlier by the corresponding UP transition.
  #
  # @author Lenno Nagel
  class Flag < ActiveRecord::Base
    include ESA::Traits::Extendable
    extend ::Enumerize

    attr_accessible :nature, :state, :event, :time, :accountable, :type, :ruleset
    attr_readonly   :nature, :state, :event, :time, :accountable, :type, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :event
    belongs_to :ruleset
    has_many   :transactions
    has_many   :amounts, :through => :transactions, :extend => ESA::Associations::AmountsExtension

    scope :transitioning, lambda { joins(:event).where("esa_events.nature = 'adjustment' OR esa_flags.transition != 0").readonly(false) }

    enumerize :nature, in: [:unknown]

    after_initialize :initialize_defaults
    validates_presence_of :nature, :event, :time, :accountable, :ruleset
    validates_inclusion_of :state, :in => [true, false]
    validates_inclusion_of :processed, :in => [true, false]
    validates_inclusion_of :adjusted, :in => [true, false]
    validate :validate_transition

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

    def matches_spec?(spec)
      self.nature == spec[:nature].to_s and
      self.state == spec[:state]
    end

    def transactions_match_specs?(specs)
      if self.transactions.count == specs.count
        self.transactions.map do |tx|
          tx_spec = specs.find{|a| a[:description] == tx.description} || {}
          tx.matches_spec?(tx_spec)
        end.all?
      else
        false
      end
    end

    private

    def validate_transition
      if self.processed and not self.transition.in? [-1, 0, 1]
        errors[:processed] = "The transition must be in? [-1, 0, 1] before processed can be set to true"
      end
      if self.adjusted and not self.transition.in? [-1, 0, 1]
        errors[:adjusted] = "The transition must be in? [-1, 0, 1] before adjusted can be set to true"
      end
    end

    def initialize_defaults
      if not self.event_id.nil?
        self.time ||= self.event.time if self.time.nil?
        self.accountable ||= self.event.accountable if self.accountable_id.nil?
        self.ruleset ||= self.event.ruleset if self.ruleset_id.nil?
      end

      self.processed ||= false
      self.adjusted ||= false
    end
  end
end
