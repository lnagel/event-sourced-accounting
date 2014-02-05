require 'spec_helper'

module ESA
  describe Revenue do
    it_behaves_like 'a ESA::Account subtype', kind: :revenue, normal_balance: :credit
  end
end