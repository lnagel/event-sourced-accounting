module ESA
  module Associations
    module FlagsExtension
      def is_set?(nature, time=Time.zone.now, exclude=nil)
        query = where(nature: nature).
              where('time <= ?', time)

        if exclude.present?
          query = query.where('esa_flags.id not in (?)', exclude)
        end

        most_recent = query.
              order('time DESC, created_at DESC').first

        if most_recent.present?
          most_recent.is_set? # return the set bit of this flag
        else
          false
        end
      end

      def transition_for(flag)
        if flag.state and not is_set?(flag.nature, flag.time, flag.id)
          1
        elsif not flag.state and is_set?(flag.nature, flag.time, flag.id)
          -1
        else
          0
        end
      end
    end
  end
end
