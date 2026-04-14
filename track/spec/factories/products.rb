FactoryBot.define do
  factory :product, class: Product do
    name { "MyString" }
    description { "MyText" }
    price { 1 }
    status { 1 }
    published_at { "2026-04-09 09:26:25" }
    deleted_at { "2026-04-09 09:26:25" }
  end
end
