FactoryBot.define do
  factory :rating do
    association :post, factory: :post
    association :user, factory: :user
    value { rand(1..5) }
  end
end
