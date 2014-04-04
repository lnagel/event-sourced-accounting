FactoryGirl.define do
  factory :account, :class => ESA::Account do |account|
    account.code
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :asset, :class => ESA::Accounts::Asset do |account|
    account.code
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :equity, :class => ESA::Accounts::Equity do |account|
    account.code
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :expense, :class => ESA::Accounts::Expense do |account|
    account.code
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :liability, :class => ESA::Accounts::Liability do |account|
    account.code
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :revenue, :class => ESA::Accounts::Revenue do |account|
    account.code
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  sequence :name do |n|
    "Factory Name #{n}"
  end

  sequence :code do |n|
    "#{n}"
  end
end
