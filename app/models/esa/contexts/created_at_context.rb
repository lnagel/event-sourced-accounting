module ESA
  module Contexts
    class CreatedAtContext < ESA::Context
      def created_at
        @created_at
      end

      def created_at=(timespec)
        @created_at = timespec
        @filters = [lambda { |relation| relation.where(created_at: timespec) }]
      end

      def effective_path
        if self.parent_id.blank?
          []
        else
          self.parent.effective_path
        end
      end

      def can_be_persisted?
        false
      end
    end
  end
end
