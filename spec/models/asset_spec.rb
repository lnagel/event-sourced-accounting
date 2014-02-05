require 'spec_helper'

module ESA
  describe Asset do
    it_behaves_like 'a ESA::Account subtype', kind: :asset, normal_balance: :debit
  end
end
