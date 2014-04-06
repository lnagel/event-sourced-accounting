# ESA
require "rails"
require "enumerize"

require 'esa/account'
require 'esa/accounts/asset'
require 'esa/accounts/equity'
require 'esa/accounts/expense'
require 'esa/accounts/liability'
require 'esa/accounts/revenue'
require 'esa/amount'
require 'esa/amounts/credit'
require 'esa/amounts/debit'
require 'esa/associations/amounts_extension'
require 'esa/associations/events_extension'
require 'esa/associations/flags_extension'
require 'esa/associations/transactions_extension'
require 'esa/chart'
require 'esa/context'
require 'esa/contexts/accountable_context'
require 'esa/contexts/accountable_type_context'
require 'esa/contexts/account_context'
require 'esa/contexts/created_at_context'
require 'esa/contexts/date_context'
require 'esa/contexts/empty_context'
require 'esa/contexts/filter_context'
require 'esa/contexts/open_close_context'
require 'esa/event'
require 'esa/flag'
require 'esa/ruleset'
require 'esa/traits/accountable'
require 'esa/traits/extendable'
require 'esa/traits/or_scope'
require 'esa/traits/union_scope'
require 'esa/transaction'

require 'esa/blocking_processor'
require 'esa/balance_checker'
require 'esa/subcontext_checker'

require 'esa/context_provider'
require 'esa/context_providers/accountable_context_provider'
require 'esa/context_providers/accountable_type_context_provider'
require 'esa/context_providers/account_context_provider'
require 'esa/context_providers/date_context_provider'

require 'esa/filters/account_filter'
require 'esa/filters/accountable_filter'
require 'esa/filters/accountable_type_filter'
require 'esa/filters/chart_filter'
require 'esa/filters/context_filter'
require 'esa/filters/date_time_filter'

require 'esa/config'

module ESA
  class Engine < Rails::Engine
    isolate_namespace ESA
  end
end
