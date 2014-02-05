require 'spec_helper'

module ESA
  describe CreditAmount do
    it_behaves_like 'a ESA::Amount subtype', kind: :credit_amount
  end
end
