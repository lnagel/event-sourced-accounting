shared_examples_for 'a ESA::Account subtype' do |elements|
  let(:contra) { false }
  let(:account) { FactoryGirl.create(elements[:kind], contra: contra)}
  subject { account }

  describe "instance methods" do
    its(:balance) { should be_kind_of(BigDecimal) }
    its(:normal_balance) { should be_kind_of(Enumerize::Value) }

    it { should respond_to(:transactions) }
  end

  it "requires a name" do
    account.name = nil
    account.should_not be_valid
  end

  # Figure out which way credits and debits should apply
  if elements[:normal_balance] == :debit
      contra_balance = :credit
     debit_condition = :>
    credit_condition = :<
  else
      contra_balance = :debit
    credit_condition = :>
     debit_condition = :<
  end

  describe "stored normal balance" do
    its(:normal_balance) { should eq(elements[:normal_balance].to_s) }

    describe "on a contra account" do
      let(:contra) { true }
      its(:normal_balance) { should eq(contra_balance.to_s) }
    end
  end

  describe "when given a debit" do
    before { FactoryGirl.create(:debit_amount, account: account) }
    its(:balance) { should be.send(debit_condition, 0) }

    describe "on a contra account" do
      let(:contra) { true }
      its(:balance) { should be.send(credit_condition, 0) }
    end
  end

  describe "when given a credit" do
    before { FactoryGirl.create(:credit_amount, account: account) }
    its(:balance) { should be.send(credit_condition, 0) }

    describe "on a contra account" do
      let(:contra) { true }
      its(:balance) { should be.send(debit_condition, 0) }
    end
  end
end
