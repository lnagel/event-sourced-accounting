module ESA
  class Flag < ActiveRecord::Base
    include Traits::Extendable
    extend ::Enumerize

    attr_accessible :nature, :state, :event, :time, :accountable, :type, :ruleset
    attr_readonly   :nature, :state, :event, :time, :accountable, :type, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :event
    belongs_to :ruleset
    has_many   :transactions
    has_many   :amounts, :through => :transactions, :extend => Associations::AmountsExtension

    enumerize :nature, in: [:unknown]

    after_initialize :default_values
    validates_presence_of :nature, :event, :time, :accountable, :ruleset
    validates_inclusion_of :state, :in => [true, false]
    validates_inclusion_of :processed, :in => [true, false]
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

    def produce_transactions
      transactions = self.transactions.all
      if self.ruleset.present? and self.transition.present?
        required_transactions = self.ruleset.flag_transactions_as_attributes(self)
        required_transactions.map do |attrs|
          existing = transactions.find{|f| f.description == attrs[:description]}
          if existing.present?
            existing
          else
            self.accountable.esa_transactions.new(attrs)
          end
        end
      else
        transactions
      end
    end

    def create_transactions
      if not self.processed and not self.processed_was
        if self.transition.present?
          self.produce_transactions.map(&:save).all?
        else
          false
        end
      else
        true
      end
    end

    private

    def validate_transition
      if self.processed and not self.transition.in? [-1, 0, 1]
        errors[:processed] = "The transition must be in? [-1, 0, 1] before processed can be set to true"
      end
    end

    def default_values
      if not self.event_id.nil?
        self.time ||= self.event.time if self.time.nil?
        self.accountable ||= self.event.accountable if self.accountable_id.nil?
        self.ruleset ||= self.event.ruleset if self.ruleset_id.nil?
      end

      self.processed ||= false
    end
  end
end
