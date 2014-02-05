FactoryGirl.define do
  factory :account, :class => ESA::Account do |account|
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :asset, :class => ESA::Asset do |account|
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :equity, :class => ESA::Equity do |account|
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :expense, :class => ESA::Expense do |account|
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :liability, :class => ESA::Liability do |account|
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  factory :revenue, :class => ESA::Revenue do |account|
    account.name
    account.contra false
    account.association :chart, :factory => :chart
  end

  sequence :name do |n|
    "Factory Name #{n}"
  end
end
