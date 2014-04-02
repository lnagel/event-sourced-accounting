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
            order('time ASC, created_at ASC')

        unprocessed_events.each do |event|
          event.processed = process_event(event)
          event.save if event.changed?
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
        unrecorded_events = ruleset.unrecorded_events_as_attributes(accountable)
        accountable.esa_events.new(unrecorded_events)
      else
        []
      end
    end

    def self.process_event(event)
      flags_created = create_flags(event)

      if flags_created
        unprocessed_flags = event.flags.
            where(processed: false).
            order('time ASC, created_at ASC')

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
      flags = event.flags.all
      if event.ruleset.present?
        required_flags = event.ruleset.event_flags_as_attributes(event)
        required_flags.map do |attrs|
          existing = flags.find{|f| f.nature == attrs[:nature].to_s and f.state == attrs[:state]}
          if existing.present?
            existing
          else
            flag = event.accountable.esa_flags.new(attrs)
            event.flags << flag
            flag
          end
        end
      else
        flags
      end
    end

    def self.process_flag(flag)
      flag.transition = flag.accountable.esa_flags.transition_for(flag)
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
