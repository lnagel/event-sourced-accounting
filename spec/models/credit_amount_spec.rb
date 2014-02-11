require 'spec_helper'

module ESA
  module Amounts
    describe Credit do
      it_behaves_like 'a ESA::Amount subtype', kind: :credit_amount
    end
  end
end
