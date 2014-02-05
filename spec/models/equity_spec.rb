require 'spec_helper'

module ESA
  describe Equity do
    it_behaves_like 'a ESA::Account subtype', kind: :equity, normal_balance: :credit
  end
end
