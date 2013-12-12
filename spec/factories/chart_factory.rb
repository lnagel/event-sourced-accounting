FactoryGirl.define do
  factory :chart, :class => Plutus::Chart do
    id 1
    name "Chart of Accounts"
    initialize_with { Plutus::Chart.find_or_create_by_id(id)}
  end
end
