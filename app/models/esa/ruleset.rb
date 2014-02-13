module ESA
  class Ruleset < ActiveRecord::Base
    include Traits::Extendable

    attr_accessible :name, :type, :chart
    attr_readonly   :name, :type, :chart

    belongs_to :chart
    has_many   :events
    has_many   :flags

    after_initialize :default_values
    validates_presence_of :type, :chart

    def accountable_events(accountable)
      []
    end

    def accountable_events_as_attributes(accountable)
      accountable_events(accountable).map do |event|
        event[:accountable] ||= accountable
        event[:ruleset] ||= self
        event
      end
    end

    def event_flags(event)
      {}
    end

    def event_flags_as_attributes(event)
      event_flags(event).map do |nature,state|
        {
          :accountable => event.accountable,
          :nature => nature,
          :state => state,
          :event => event,
        }
      end
    end

    def flag_transactions_when_set(flag)
      []
    end

    def flag_transactions_when_unset(flag)
      self.flag_transactions_when_set(flag).each do |tx|
        description = tx[:description] + " / reversed"
        debits = tx[:credits] # swap
        credits = tx[:debits] # swap
        tx[:description] = description
        tx[:debits] = debits
        tx[:credits] = credits
      end
    end

    def flag_transactions_as_attributes(flag)
      if flag.became_set?
        transactions = self.flag_transactions_when_set(flag)
      elsif flag.became_unset?
        transactions = self.flag_transactions_when_unset(flag)
      else
        transactions = []
      end

      transactions.map do |tx|
        tx[:time] ||= flag.time
        tx[:accountable] ||= flag.accountable
        tx[:flag] ||= flag
        tx
      end
    end

    def find_account(type, name)
      if self.chart.present? and Account.valid_type?(type)
        # .first_or_create doesnt seem to be reliable: it creates duplicates
        Account.where(chart_id: self.chart, type: Account.namespaced_type(type), name: name).first
      end
    end

    private

    def default_values
      self.chart ||= Chart.extension_instance(self)
    end
  end
end
