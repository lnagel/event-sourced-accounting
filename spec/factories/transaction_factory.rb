FactoryGirl.define do
  factory :transaction, :class => ESA::Transaction do |transaction|
    transaction.description 'factory description'
    factory :transaction_with_credit_and_debit, :class => ESA::Transaction do |transaction_cd|
      transaction_cd.after_build do |t|
        t.amounts << FactoryGirl.build(:credit_amount, :transaction => t)
        t.amounts << FactoryGirl.build(:debit_amount, :transaction => t)
      end
    end
  end
end