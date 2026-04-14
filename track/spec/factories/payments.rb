FactoryBot.define do
  factory :payment_jpyc, class: Payment do
    id { 1 }
    name { "JPYC" }
    status { 1 }
  end

  factory :payment_stripe, class: Payment do
    id { 2 }
    name { "Stripe" }
    status { 1 }
  end
end
