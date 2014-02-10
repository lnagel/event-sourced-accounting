module ESA
  class Flag < ActiveRecord::Base
    include Extendable
    extend ::Enumerize

    attr_accessible :nature, :state, :event, :time, :accountable, :type, :ruleset
    attr_readonly   :nature, :state, :transition, :event, :time, :accountable, :type, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :event
    belongs_to :ruleset
    has_many   :transactions

    enumerize :nature, in: [:unknown]

    after_initialize :default_values
    validates_presence_of :nature, :state, :transition, :event, :time, :accountable, :ruleset
    validates_inclusion_of :state, :in => [true, false]
    validates_inclusion_of :transition, :in => [1, 0, -1]

    after_create :create_transactions

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
      if self.ruleset.present?
        transactions = self.ruleset.flag_transactions_as_attributes(self)
        transactions.map do |attrs|
          self.accountable.esa_transactions.new(attrs)
        end
      else
        []
      end
    end

    def create_transactions
      self.produce_transactions.map(&:save).all?
    end

    private

    def default_values
      if not self.event.nil?
        self.event ||= event
        self.time ||= event.time
        self.accountable ||= event.accountable
        self.ruleset ||= event.ruleset
      end

      if not self.accountable.nil? and not self.nature.nil? and not self.state.nil? and not self.time.nil?
        self.transition ||= event.accountable.esa_flags.transition(self.nature, self.state, self.time)
      end
    end
  end
end
