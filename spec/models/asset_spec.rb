require 'spec_helper'

module ESA
  module Accounts
    describe Asset do
      it_behaves_like 'a ESA::Account subtype', kind: :asset, normal_balance: :debit
    end
  end
end
