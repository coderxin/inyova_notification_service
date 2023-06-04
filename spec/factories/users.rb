# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{SecureRandom.random_number(n * 1000)}@inyova.com" }
    password { 'qwerty' }

    trait :admin do
      admin { true }
    end
  end
end
