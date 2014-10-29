module ESA
  module Traits
    module Accountable
      extend ActiveSupport::Concern

      included do
        has_one  :esa_state,        :as => :accountable, :class_name => ESA::State, dependent: :destroy
        has_many :esa_events,       :as => :accountable, :class_name => ESA::Event.extension_name(self),       :extend => ESA::Associations::EventsExtension
        has_many :esa_flags,        :as => :accountable, :class_name => ESA::Flag.extension_name(self),        :extend => ESA::Associations::FlagsExtension
        has_many :esa_transactions, :as => :accountable, :class_name => ESA::Transaction.extension_name(self), :extend => ESA::Associations::TransactionsExtension

        scope :esa_processed_at, lambda { |timespec|
          joins("INNER JOIN `esa_states` ON `esa_states`.`accountable_id` = `#{table_name}`.`#{primary_key}` AND `esa_states`.`accountable_type` = '#{self}'").
              where(esa_states: {processed_at: timespec}).
              readonly(false)
        }

        scope :esa_unprocessed, lambda {
          joins("LEFT JOIN `esa_states` ON `esa_states`.`accountable_id` = `#{table_name}`.`#{primary_key}` AND `esa_states`.`accountable_type` = '#{self}'").
              where("`esa_states`.`id` IS NULL").
              readonly(false)
        }



        before_destroy :destroy_accountable

        def esa_ruleset
          ESA::Ruleset.extension_instance(self)
        end

        def esa_chart
          self.esa_ruleset.chart
        end

        def destroy_accountable
          if self.esa_transactions.blank?
            self.esa_states.delete_all
            self.esa_flags.delete_all
            self.esa_events.delete_all
          else
            false
          end
        end
      end
    end
  end
end
