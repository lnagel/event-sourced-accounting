require 'spec_helper'

module ESA
  module Accounts
    describe Equity do
      it_behaves_like 'a ESA::Account subtype', kind: :equity, normal_balance: :credit
    end
  end
end
