FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Producto #{n}" }
    sequence(:slug) { |n| "producto-#{n}" }
    description { "Un producto de prueba" }
    price { 250.00 }
    stock_quantity { 10 }
    kind { "physical" }
    requires_shipping { true }
    shipping_cost { 50.00 }
    active { true }

    trait :digital do
      kind { "digital" }
      requires_shipping { false }
      shipping_cost { 0 }
    end
  end
end
