module ESA
  module Contexts
    class DateContext < ESA::Context
      attr_accessible :start_date, :end_date
      attr_readonly   :start_date, :end_date

      validate :validate_dates

      def preceeding_context
        if self.start_date.present?
          DateContext.new chart: self.chart,
                          end_date: self.start_date - 1.day
        else
          nil
        end
      end

      def following_context
        if self.end_date.present?
          DateContext.new chart: self.chart,
                          start_date: self.end_date + 1.day
        else
          nil
        end
      end

      protected

      def validate_dates
        if self.start_date.nil? and self.end_date.nil?
          errors[:start_date] = "at least one of the two dates must be provided"
          errors[:end_date] = "at least one of the two dates must be provided"
        end
      end

      def create_name
        if self.start_date.present? and self.end_date.present?
          if self.start_date == self.end_date
            "#{self.start_date.to_s}"
          else
            "#{self.start_date.to_s} - #{self.end_date.to_s}"
          end
        elsif self.start_date.present?
          "#{self.start_date.to_s} - ..."
        elsif self.end_date.present?
          "... - #{self.end_date.to_s}"
        end
      end

      def initialize_filters
        @filters = []

        if self.start_date.present? and self.end_date.present?
          @filters << lambda { |relation| relation.between_dates(self.start_date, self.end_date) }
        elsif self.start_date.present?
          @filters << lambda { |relation| relation.with_date_gte(self.start_date) }
        elsif self.end_date.present?
          @filters << lambda { |relation| relation.with_date_lte(self.end_date) }
        end
      end
    end
  end
end
