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

    def stateful_events(accountable)
      []
    end

    def stateful_events_as_attributes(accountable)
      stateful_events(accountable).
        sort_by{|event| event[:time]}.
        map do |event|
          event[:accountable] ||= accountable
          event[:ruleset] ||= self
          event
        end
    end

    def unrecorded_events(accountable)
      stateful = stateful_events_as_attributes(accountable)

      recorded = accountable.esa_events.pluck([:nature, :time]).
            map{|nature,time| [nature, time.to_i]}

      stateful.reject{|s| [s[:nature].to_s, s[:time].to_i].in? recorded}
    end

    def produce_unrecorded_events(accountable)
      accountable.esa_events.new(unrecorded_events(accountable))
    end

    def create_unrecorded_events(accountable)
      produce_unrecorded_events(accountable).map(&:save).all?
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
        self.chart.accounts.
          where(:type => Account.namespaced_type(type), :name => name).
          first_or_create
      end
    end

    private

    def default_values
      self.chart ||= Chart.extension_instance(self) if self.chart_id.nil?
    end
  end
end
