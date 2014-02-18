module ESA
  module Filters
    module ChartFilter
      extend ActiveSupport::Concern

      included do
        scope :with_chart, lambda { |chart| with_account(Account.where(chart_id: chart)) }
        scope :with_chart_name, lambda { |name| with_chart(Chart.where(name: name)) }
      end
    end
  end
end

ESA::Amount.send :include, ESA::Filters::ChartFilter
ESA::Event.send :include, ESA::Filters::ChartFilter
ESA::Flag.send :include, ESA::Filters::ChartFilter
ESA::Transaction.send :include, ESA::Filters::ChartFilter
