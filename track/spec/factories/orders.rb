FactoryBot.define do
  factory :order do
    uuid { SecureRandom.uuid }
    price { 1 }
    status { :pending }
    deleted_at { nil }

    # 関連するモデルを自動生成
    association :product
    association :address
    association :payment
  end
end
