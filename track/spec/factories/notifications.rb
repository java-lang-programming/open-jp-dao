FactoryBot.define do
  factory :notification_start_at_now, class: Notification do
    message { "test" }
    start_at { Time.now }
    end_at { Time.now.since(1.months) }
    priority { 1 }
  end

  factory :notification_start_at_tomorrow, class: Notification do
    message { "test2" }
    start_at { Time.now.tomorrow }
    end_at { Time.now.since(1.months) }
    priority { 1 }
  end
end
