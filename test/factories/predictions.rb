FactoryBot.define do
  factory :prediction do
    association :user
    association :match, :open
    advancing_pick { "México" }
  end
end
