FactoryGirl.define do
  factory :chart, :class => ESA::Chart do
    id 1
    name "Chart of Accounts"
    initialize_with { ESA::Chart.find_or_create_by_id(id)}
  end
end
