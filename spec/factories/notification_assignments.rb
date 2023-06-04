# frozen_string_literal: true

FactoryBot.define do
  factory :notification_assignment do
    trait :seen do
      seen_at { Time.current }
    end
  end
end
