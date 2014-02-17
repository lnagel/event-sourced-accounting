require 'spec_helper'

module ESA
  describe Chart do
    let(:chart) { FactoryGirl.build(:chart) }
    subject { chart }

    its(:trial_balance) { should be_kind_of BigDecimal }
    
    context "when given no transactions" do
      its(:trial_balance) { should == 0 }
    end
    
    context "when given correct transactions" do
      before {
        # credit accounts
        liability = FactoryGirl.create(:liability)
        equity = FactoryGirl.create(:equity)
        revenue = FactoryGirl.create(:revenue)
        contra_asset = FactoryGirl.create(:asset, :contra => true)
        contra_expense = FactoryGirl.create(:expense, :contra => true)
        # credit amounts
        ca1 = FactoryGirl.build(:credit_amount, :account => liability, :amount => 100000)
        ca2 = FactoryGirl.build(:credit_amount, :account => equity, :amount => 1000)
        ca3 = FactoryGirl.build(:credit_amount, :account => revenue, :amount => 40404)
        ca4 = FactoryGirl.build(:credit_amount, :account => contra_asset, :amount => 2)
        ca5 = FactoryGirl.build(:credit_amount, :account => contra_expense, :amount => 333)

        # debit accounts
        asset = FactoryGirl.create(:asset)
        expense = FactoryGirl.create(:expense)
        contra_liability = FactoryGirl.create(:liability, :contra => true)
        contra_equity = FactoryGirl.create(:equity, :contra => true)
        contra_revenue = FactoryGirl.create(:revenue, :contra => true)
        # debit amounts
        da1 = FactoryGirl.build(:debit_amount, :account => asset, :amount => 100000)
        da2 = FactoryGirl.build(:debit_amount, :account => expense, :amount => 1000)
        da3 = FactoryGirl.build(:debit_amount, :account => contra_liability, :amount => 40404)
        da4 = FactoryGirl.build(:debit_amount, :account => contra_equity, :amount => 2)
        da5 = FactoryGirl.build(:debit_amount, :account => contra_revenue, :amount => 333)

        FactoryGirl.create(:transaction, :amounts => [ca1, da1])
        FactoryGirl.create(:transaction, :amounts => [ca2, da2]) 
        FactoryGirl.create(:transaction, :amounts => [ca3, da3])
        FactoryGirl.create(:transaction, :amounts => [ca4, da4])
        FactoryGirl.create(:transaction, :amounts => [ca5, da5])
      }
      
      its(:trial_balance) { should == 0 }
    end
  end
end
