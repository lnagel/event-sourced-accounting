module ESA
  class BlockingProcessor
    def self.enqueue(accountable)
      if accountable.present? and accountable.class.ancestors.include? ESA::Traits::Accountable
        process_accountable(accountable)
      end
    end

    def self.process_accountable(accountable)
      events_created = create_events(accountable)

      if events_created
        unprocessed_events = accountable.esa_events.
            where(processed: false).
            order(:time, :created_at, :id)

        unprocessed_events.each do |event|
          event.processed = process_event(event)
          event.save if event.changed?

          # do not process later events if one fails
          return false if not event.processed
        end
      else
        false
      end
    end

    def self.create_events(accountable)
      produce_events(accountable).map(&:save).all?
    end

    def self.produce_events(accountable)
      ruleset = Ruleset.extension_instance(accountable)
      if ruleset.present?
        last_event_time = accountable.esa_events.maximum(:time)
        unrecorded_events = ruleset.unrecorded_events_as_attributes(accountable)
        valid_events = unrecorded_events.select{|e| last_event_time.nil? or e[:time] >= last_event_time}
        accountable.esa_events.new(valid_events)
      else
        []
      end
    end

    def self.process_event(event)
      flags_created = create_flags(event)

      if flags_created
        unprocessed_flags = []

        if event.nature.adjustment?
          unprocessed_flags += event.accountable.esa_flags.
              where(adjusted: true, processed: false).
              order(:time, :created_at, :id)
        end

        unprocessed_flags += event.flags.
            where(processed: false).
            order(:time, :created_at, :id)

        unprocessed_flags.map do |flag|
          flag.processed = process_flag(flag)
          if flag.changed?
            flag.save and flag.processed
          else
            flag.processed
          end
        end.all?
      else
        false
      end
    end

    def self.create_flags(event)
      if not event.processed and not event.processed_was
        produce_flags(event).map(&:save).all?
      else
        true
      end
    end

    def self.produce_flags(event)
      if event.nature.adjustment?
        produce_flags_for_adjustment(event)
      else
        produce_flags_for_regular(event)
      end
    end

    def self.produce_flags_for_adjustment(event)
      if event.ruleset.present?
        adjusted_flags = event.ruleset.flags_needing_adjustment(event.accountable)
        adjusted_flags.map do |flag|
          flag.processed = false
          flag.adjusted = true
          flag.adjustment_time = event.time

          attrs = {
            :accountable => event.accountable,
            :nature => flag.nature,
            :state => flag.state,
            :event => event,
          }

          adjustment = event.accountable.esa_flags.new(attrs)
          event.flags << adjustment

          [flag, adjustment]
        end.flatten
      else
        []
      end
    end

    def self.produce_flags_for_regular(event)
      if event.ruleset.present?
        existing_flags = event.flags.all
        required_flags = event.ruleset.event_flags_as_attributes(event)

        required_flags.map do |attrs|
          flag = existing_flags.find{|f| f.nature == attrs[:nature].to_s and f.state == attrs[:state]}

          if flag.nil?
            flag = event.accountable.esa_flags.new(attrs)
            event.flags << flag
          end

          flag
        end
      else
        []
      end
    end

    def self.process_flag(flag)
      flag.transition ||= flag.accountable.esa_flags.transition_for(flag)
      create_transactions(flag)
    end

    def self.create_transactions(flag)
      if not flag.processed and not flag.processed_was
        if flag.transition.present? and flag.transition.in? [-1, 0, 1]
          produce_transactions(flag).map(&:save).all?
        else
          false
        end
      else
        true
      end
    end

    def self.produce_transactions(flag)
      transactions = flag.transactions.all
      if flag.ruleset.present? and flag.transition.present? and flag.transition.in? [-1, 0, 1]
        required_transactions = flag.ruleset.flag_transactions_as_attributes(flag)
        required_transactions.map do |attrs|
          existing = transactions.find{|f| f.description == attrs[:description]}
          if existing.present?
            existing
          else
            transaction = flag.accountable.esa_transactions.new(attrs)
            flag.transactions << transaction
            transaction
          end
        end
      else
        transactions
      end
    end
  end
end
