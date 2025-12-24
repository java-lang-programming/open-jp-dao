FactoryBot.define do
  factory :external_service_transaction_type do
    external_service  { }
    name { "test" }
    transaction_type { }
    deleted_at { nil }
  end
end
