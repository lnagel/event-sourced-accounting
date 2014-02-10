module ESA
  class Ruleset < ActiveRecord::Base
    include Extendable

    attr_accessible :name, :type, :chart
    attr_readonly   :name, :type, :chart

    belongs_to :chart
    has_many   :events
    has_many   :flags

    after_initialize :default_values
    validates_presence_of :type, :chart

    # events that have happened according to the current state (expected to be overridden)
    def events_from_object_state(obj)
      []
    end

    # flags to be changed when events occur (expected to be overridden)
    def event_flags(event)
      {}
    end

    # transactions to be made when flags are set/unset
    # this makes sure all the necessary metadata is there
    def flag_transactions(flag)
      transactions = self.flag_transactions_when_set(flag)

      transactions.each do |tx|
        tx[:time] ||= flag.time
        tx[:accountable] ||= flag.accountable
        tx[:flag] ||= flag
      end

      # check if we need forward or reverse transactions
      if flag.set == true
        # return the unmodified list
        transactions
      elsif flag.set == false
        # reverse the transactions by swapping debits and credits
        transactions.each do |tx|
          description = tx[:description] + " / reversed"
          debits = tx[:credits] # swap
          credits = tx[:debits] # swap
          tx[:description] = description
          tx[:debits] = debits
          tx[:credits] = credits
        end
      end
    end

    # transactions to be made when flags are set (expected to be overridden)
    def flag_transactions_when_set(flag)
      []
    end

    private

    def default_values
      self.chart ||= Chart.extension_instance(self)
    end
  end
end
