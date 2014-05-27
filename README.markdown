[![Gem Version](https://badge.fury.io/rb/event_sourced_accounting.svg)](http://badge.fury.io/rb/event_sourced_accounting)
[![Build Status](https://api.travis-ci.org/lnagel/event-sourced-accounting.svg)](https://travis-ci.org/lnagel/event-sourced-accounting)
[![Code Climate](https://img.shields.io/codeclimate/github/lnagel/event-sourced-accounting.svg)](https://codeclimate.com/github/lnagel/event-sourced-accounting)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/lnagel/event-sourced-accounting.svg)](https://codeclimate.com/github/lnagel/event-sourced-accounting)

Event-Sourced Accounting
=================

The Event-Sourced Accounting plugin provides an event-sourced double entry accounting system.
It uses the data models of a Rails application as a data source and automatically 
generates accounting transactions based on defined accounting rules.

This plugin began life as a fork of the [Plutus](https://github.com/mbulat/plutus) plugin with
many added features and refactored compontents. As the aims of the ESA plug-in have completely
changed compared to the original project, it warrants a release under its own name.

The API is not yet declared frozen and may change, as some refactoring is still due.
The documentation and test coverage is expected to be completed within April-May 2014. 


Installation
============

- Add `gem "event_sourced_accounting"` to your Gemfile

- generate migration files with `rails g event_sourced_accounting`

- run migrations `rake db:migrate`


Integration
============

First, configure the gem by creating `config/initializers/accounting.rb`.
```
require 'esa'

ESA.configure do |config|
  config.extension_namespace = 'Accounting'
  config.register('BankTransaction')
  ...
end
```

Then add `include ESA::Traits::Accountable` to the registered models.
```
class BankTransaction < ActiveRecord::Base
  include ESA::Traits::Accountable
  ...
end
```

Implement the corresponding Event, Flag, Ruleset and Transaction classes for the registered models.
```
# app/models/accounting/events/bank_transaction_event.rb
module Accounting
  module Events
    class BankTransactionEvent < ESA::Event
      enumerize :nature, in: [
                        :adjustment, # mandatory
                        :complete,   # example
                        :revoke,     # example
                      ]
    end
  end
end
```

```
# app/models/accounting/flags/bank_transaction_flag.rb
module Accounting
  module Flags
    class BankTransactionFlag < ESA::Flag
      enumerize :nature, in: [
                        :complete, # example
                     ]
    end
  end
end
```

```
# app/models/accounting/transactions/bank_transaction_transaction.rb
module Accounting
  module Transactions
    class BankTransactionTransaction < ESA::Transaction
      # this relation definition is optional
      has_one :bank_transaction, :through => :flag, :source => :accountable, :source_type => "BankTransaction"
    end
  end
end
```

```
# app/models/accounting/rulesets/bank_transaction_ruleset.rb
module Accounting
  module Rulesets
    class BankTransactionRuleset < ESA::Ruleset
      # events that have happened according to the current state
      def event_times(bank_transaction)
        {
          complete: bank_transaction.complete_time,
          revoke: bank_transaction.revoke_time,
        }
      end
      
      # flags to be changed when events occur
      def event_nature_flags
        {
          complete: {complete: true},
          revoke: {complete: false},
        }
      end

      # transaction for when the :complete flag is switched to true
      def flag_complete_transactions(bank_transaction)
        {
          :description => 'BankTransaction completed',
          :debits => [
            {
              :account => find_account('Asset', 'Bank'),
              :amount => bank_transaction.transferred_amount
            }
          ],
          :credits => [
            {
              :account => find_account('Asset', 'Bank Transit'),
              :amount => bank_transaction.transferred_amount
            }
          ],
        }
      end
    end
  end
end
```


Development
============

Any comments and contributions are welcome. Will gladly accept patches sent via pull requests.

- run rspec tests simply with `rake`

- update documentation with `yard`
