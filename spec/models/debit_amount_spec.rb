require 'spec_helper'

module ESA
  describe DebitAmount do
    it_behaves_like 'a ESA::Amount subtype', kind: :debit_amount
  end
end