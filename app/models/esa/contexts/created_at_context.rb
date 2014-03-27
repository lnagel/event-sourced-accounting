module ESA
  module Contexts
    class CreatedAtContext < ESA::Context
      before_save :prevent_save

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

      protected

      def prevent_save
        raise "#{self.type} objects are not intended to be persisted"
      end
    end
  end
end
