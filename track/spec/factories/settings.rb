FactoryBot.define do
  factory :setting do
    address_id { 1 }
    default_year { 1 }
    language { Setting::LANGUAGE_JA }
  end
end
