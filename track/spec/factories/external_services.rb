FactoryBot.define do
  factory :external_service do
    id { ExternalService::SUMISHIN_SBI_NYUSHUKINMEISAI }
    name { '住信SBI入出金明細' }
    deleted_at { "2025-12-24 18:22:52" }
  end
end
