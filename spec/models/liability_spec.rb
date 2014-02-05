require 'spec_helper'

module ESA
  describe Liability do
    it_behaves_like 'a ESA::Account subtype', kind: :liability, normal_balance: :credit
  end
end