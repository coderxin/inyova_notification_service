# frozen_string_literal: true

FactoryBot.define do
  factory :push_notification do
    state { 'scheduled' }

    trait :delivered do
      state { 'delivered' }
    end

    trait :errored do
      state { 'errored' }
    end
  end
end
