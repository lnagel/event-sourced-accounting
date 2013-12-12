require 'spec_helper'

module Plutus
  describe Chart do
    let(:chart) { FactoryGirl.build(:chart) }
    subject { chart }
  end
end
