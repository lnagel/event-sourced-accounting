require 'spec_helper'

module ESA
  describe Chart do
    let(:chart) { FactoryGirl.build(:chart) }
    subject { chart }
  end
end
