# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    date { Time.zone.today }
    title { 'Test notification' }
    description { 'Description of the notification' }

    trait :in_the_future do
      date { Time.zone.today + 2.days }
    end

    trait :in_the_past do
      date { Time.zone.today - 2.days }
    end
  end
end
