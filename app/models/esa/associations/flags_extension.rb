module ESA
  module Associations
    module FlagsExtension
      def most_recent(nature, time=Time.zone.now, exclude=nil)
        query = where(nature: nature).
              where('esa_flags.time <= ?', time)

        if exclude.present?
          query = query.where('esa_flags.id not in (?)', exclude)
        end

        query.order('esa_flags.time DESC, esa_flags.created_at DESC').first
      end

      def is_set?(nature, time=Time.zone.now, exclude=nil)
        most_recent = most_recent(nature, time, exclude)
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
