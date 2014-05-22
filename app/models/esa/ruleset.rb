require 'esa/traits/extendable'

module ESA
  # The Ruleset class contains the business logic and rules of accounting.
  #
  # @author Lenno Nagel
  class Ruleset < ActiveRecord::Base
    include ESA::Traits::Extendable

    attr_accessible :name, :type, :chart
    attr_readonly   :name, :type, :chart

    belongs_to :chart
    has_many   :events
    has_many   :flags

    after_initialize :initialize_defaults
    validates_presence_of :type, :chart

    # accountable

    def accountables_updated_at(timespec)
      []
    end

    # events

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

    def unrecorded_events_as_attributes(accountable)
      stateful = stateful_events_as_attributes(accountable)

      recorded = accountable.esa_events.pluck([:nature, :time]).
            map{|nature,time| [nature, time.to_i]}

      stateful.reject{|s| [s[:nature].to_s, s[:time].to_i].in? recorded}
    end

    def is_adjustment_event_needed?(accountable)
      flags_needing_adjustment(accountable).count > 0
    end

    # flags

    def event_flags(event)
      self.event_nature_flags[event.nature.to_sym] || {}
    end

    def event_nature_flags
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

    def flags_needing_adjustment(accountable)
      natures = accountable.esa_flags.pluck(:nature).uniq.map{|nature| nature.to_sym}

      most_recent_flags = natures.map do |nature|
        accountable.esa_flags.transitioning.most_recent(nature)
      end.compact

      set_flags = most_recent_flags.select(&:is_set?)

      set_flags.reject do |flag|
        specs = flag_transactions_as_attributes(flag)
        flag.transactions_match_specs?(specs)
      end
    end

    # transactions

    def flag_transactions_when_set(flag)
      []
    end

    def flag_transactions_when_unset(flag)
      self.flag_transactions_when_set(flag).each do |tx|
        tx[:description] = "#{tx[:description]} / reversed"
        tx[:debits], tx[:credits] = tx[:credits], tx[:debits] # swap
      end
    end

    def flag_transactions_when_adjusted(flag)
      flag.transactions.map do |tx|
        if tx.valid?
          spec = tx.spec
          [
            # original transaction, which must be kept
            spec,
            # adjustment transaction, which must be added
            spec.merge({
              :time => flag.adjustment_time,
              :description => "#{tx.description} / adjusted",
              :debits => spec[:credits], # swap
              :credits => spec[:debits], # swap
            })
          ]
        end
      end.compact.flatten
    end

    def flag_transactions(flag)
      if flag.adjusted?
        flag_transactions_when_adjusted(flag)
      elsif flag.is_set? and (flag.became_set? or (flag.event.present? and flag.event.nature.adjustment?))
        flag_transactions_when_set(flag)
      elsif flag.became_unset?
        flag_transactions_when_unset(flag)
      else
        []
      end
    end

    def flag_transactions_as_attributes(flag)
      flag_transactions(flag).map do |tx|
        tx[:time] ||= flag.time
        tx[:accountable] ||= flag.accountable
        tx[:flag] ||= flag

        amounts = (tx[:debits] + tx[:credits]).map{|a| a[:amount]}
        if amounts.map{|a| a <= BigDecimal(0)}.all?
          tx[:debits], tx[:credits] = inverted(tx[:credits]), inverted(tx[:debits]) # invert & swap
        end

        tx
      end
    end

    def inverted(amounts)
      amounts.map{|a| a.dup.merge({amount: BigDecimal(0) - a[:amount]}) }
    end

    def find_account(type, name)
      if self.chart.present? and Account.valid_type?(type)
        self.chart.accounts.
          where(:type => Account.namespaced_type(type), :name => name).
          first_or_create
      end
    end

    private

    def initialize_defaults
      self.chart ||= Chart.extension_instance(self) if self.chart_id.nil?
      self.name ||= "#{self.chart.name} #{self.class.name.demodulize}" if self.name.nil? and self.chart_id.present?
    end
  end
end
