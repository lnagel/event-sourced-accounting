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

    def event_times(accountable)
      {}
    end

    def stateful_events(accountable)
      self.event_times(accountable).map do |nature,times|
        if times.present? and times.is_a? Time
          {nature: nature, time: times}
        elsif times.present? and times.respond_to? :each
          times.map do |t|
            if t.is_a? Time
              {nature: nature, time: t}
            else
              nil
            end
          end.compact
        else
          nil
        end
      end.flatten.compact
    end

    def stateful_events_as_attributes(accountable)
      defaults = {
        accountable: accountable,
        ruleset: self,
      }
      stateful_events(accountable).map do |event|
        defaults.merge(event)
      end
    end

    def unrecorded_events_as_attributes(accountable)
      stateful = stateful_events_as_attributes(accountable)

      recorded = accountable.esa_events.pluck([:nature, :time]).
            map{|nature,time| [nature, time.to_i]}

      stateful.reject{|s| [s[:nature].to_s, s[:time].to_i].in? recorded}
    end

    def addable_unrecorded_events_as_attributes(accountable)
      flag_times_max = accountable.esa_flags.group(:nature).maximum(:time)

      unrecorded_events_as_attributes(accountable).select do |event|
        event_flags = event_nature_flags[event[:nature]] || {}
        flag_times = flag_times_max.slice(*event_flags.keys.map(&:to_s))

        # allow when the event flags have not been used before or
        # when all the currently used flag times are before the new event
        flag_times.values.none? || flag_times.values.max <= event[:time]
      end
    end

    def is_adjustment_event_needed?(accountable)
      flags_needing_adjustment(accountable).count > 0
    end

    # flags

    def event_nature_flags
      {}
    end

    def event_flags_as_attributes(event)
      flags = self.event_nature_flags[event.nature.to_sym] || {}
      flags.map do |nature,state|
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

      most_recent_flags.select do |flag|
        flag.is_set? and not flag_transactions_match_specs?(flag)
      end
    end

    # transactions

    def flag_transactions_spec(accountable, flag_nature)
      function_name = "flag_#{flag_nature}_transactions"

      if self.respond_to? function_name
        transactions = self.send(function_name, accountable)

        if transactions.is_a? Hash
          [transactions]
        elsif transactions.is_a? Array
          transactions
        else
          []
        end
      else
        []
      end
    end

    def flag_transactions_when_set(flag)
      flag_transactions_spec(flag.accountable, flag.nature)
    end

    def flag_transactions_when_unset(flag)
      self.flag_transactions_when_set(flag).map do |tx|
        tx.merge({
          description: "#{tx[:description]} / reversed",
          debits: tx[:credits],
          credits: tx[:debits]
        })
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
      defaults = {
        time: flag.time,
        accountable: flag.accountable,
        flag: flag,
      }
      flag_transactions(flag).map do |tx|
        attrs = defaults.merge(tx)
        ensure_positive_amounts(attrs)
      end
    end

    def flag_transactions_match_specs?(flag)
      specs = flag_transactions_as_attributes(flag)
      flag.transactions_match_specs?(specs)
    end

    def ensure_positive_amounts(attrs)
      amounts = attrs[:debits] + attrs[:credits]
      nonpositives = amounts.map{|a| a[:amount] <= BigDecimal(0)}

      if nonpositives.all?
        attrs.merge({
          debits: inverted(attrs[:credits]),
          credits: inverted(attrs[:debits]),
        })
      else
        attrs
      end
    end

    def inverted(amounts)
      amounts.map{|a| a.dup.merge({amount: BigDecimal(0) - a[:amount]}) }
    end

    def find_account(type, name)
      if self.chart.present? and Account.valid_type?(type)
        Account.namespaced_type(type).constantize.
          where(:chart_id => self.chart, :name => name).
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
