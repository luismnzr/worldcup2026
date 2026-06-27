FactoryBot.define do
  factory :member_post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:slug)  { |n| "post-#{n}" }
    excerpt { "Resumen breve" }
    body { "Contenido del post para miembros." }
    published_at { 1.hour.ago }

    trait :draft do
      published_at { nil }
    end
  end
end
