require 'spec_helper'

module ESA
  describe Account do
    let(:account) { FactoryGirl.build(:account) }
    subject { account }
    
    # must construct a child type instead
    it { should_not be_valid }

    # must respond to normal_balance, but always answer "none"
    it { should respond_to(:normal_balance) }
    its(:normal_balance) { should be_kind_of(Enumerize::Value) }
    its(:normal_balance) { should eq("none") }

    # must respond to balance, but always answer nil
    it { should respond_to(:balance) }
    its(:balance) { should be_nil }

    describe "when using a child type" do
      let(:account) { FactoryGirl.create(:account, type: "Finance::Asset") }
      it { should be_valid }
      
      it "should be unique per name" do
        conflict = FactoryGirl.build(:account, name: account.name, type: account.type)
        conflict.should_not be_valid
        conflict.errors[:name].should == ["has already been taken"]
      end
    end
  end
end
