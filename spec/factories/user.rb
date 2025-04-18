FactoryBot.define do
  factory :user do
    login { FFaker::Internet.unique.user_name }
  end
end
