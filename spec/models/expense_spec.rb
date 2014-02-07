require 'spec_helper'

module ESA
  module Accounts
    describe Expense do
      it_behaves_like 'a ESA::Account subtype', kind: :expense, normal_balance: :debit
    end
  end
end
