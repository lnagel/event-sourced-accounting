module ESA
  module Associations
    module FlagsExtension
      def is_set?(nature, time=Time.zone.now)
        most_recent = where(nature: nature).
              where('time <= ?', time).
              order('time DESC, created_at DESC').first

        if most_recent.present?
          most_recent.is_set? # return the set bit of this flag
        else
          false
        end
      end

      def transition(nature, state, time)
        if state and not is_set?(nature, time)
          1
        elsif not state and is_set?(nature, time)
          -1
        else
          0
        end
      end
    end
  end
end
