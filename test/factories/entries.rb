FactoryBot.define do
  factory :entry do
    association :user
    association :tournament
    status { :pending }
    amount { 50 }

    trait :paid do
      status { :paid }
      paid_at { Time.current }
      sequence(:stripe_checkout_session_id) { |n| "cs_test_entry_#{n}" }
    end
  end
end
