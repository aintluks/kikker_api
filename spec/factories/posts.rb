FactoryBot.define do
  factory :post do
    association :user
    title { FFaker::Lorem.sentence }
    body { FFaker::Lorem.paragraph }
    ip { FFaker::Internet.unique.ip_v4_address }
  end
end
