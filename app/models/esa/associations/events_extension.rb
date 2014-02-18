module ESA
  module Associations
    module EventsExtension
      # This function adds an event only if there were no previous events,
      # or the previous event was a different one, avoiding duplicates.
      def maybe(attrs)
        events = proxy_association.owner.esa_events
        last_event = events.order('time DESC, created_at DESC').first

        # make sure that the previous event was not of the same event type
        if last_event.nil? or last_event.nature != attrs[:nature]
          if attrs[:time].present? and last_event.present? and last_event.time.present? and last_event.time > attrs[:time]
            # we cannot input past events, so let's make it most recent
            attrs[:time] = last_event.time
            e = events.new(attrs)
          else
            e = events.new(attrs)
          end
          e.save
        else
          # we didn't need to add anything
          true
        end
      end

      def hashes
        proxy_association.owner.esa_events.
            map{|e| {:nature => e.nature, :time => e.time}}.
            sort_by{|e| e[:time]}
      end
    end
  end
end
