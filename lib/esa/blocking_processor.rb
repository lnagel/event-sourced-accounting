module ESA
  class BlockingProcessor
    def self.enqueue(accountable)
      if accountable.present? and accountable.class.ancestors.include? ESA::Traits::Accountable
        process_accountable(accountable)
      end
    end

    def self.process_accountable(accountable)
      unprocessed_events = accountable.esa_events.
          where(processed: false).
          order('time ASC, created_at ASC')

      unprocessed_events.each do |event|
        event.processed = process_event(accountable, event)
        event.save if event.changed?
      end
    end

    def self.process_event(accountable, event)
      flags_created = event.create_flags

      if flags_created
        unprocessed_flags = event.flags.
            where(processed: false).
            order('time ASC, created_at ASC')

        unprocessed_flags.map do |flag|
          flag.processed = process_flag(accountable, event, flag)
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

    def self.process_flag(accountable, event, flag)
      flag.transition = accountable.esa_flags.transition_for(flag)
      flag.create_transactions
    end
  end
end
