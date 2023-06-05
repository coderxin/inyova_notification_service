# frozen_string_literal: true

require 'securerandom'

notification_future = Notification.create(
  title: 'New ticker is available: TSLA',
  description: 'Rich description of the TSLA ticker',
  date: Date.tomorrow
)

notification_today = Notification.create(
  title: 'New ticker is available: NFLX',
  description: 'Rich description of the NFLX ticker',
  date: Date.today
)

notification_past = Notification.create(
  title: 'New ticker is available: AMZN',
  description: 'Rich description of the AMZN ticker',
  date: Date.yesterday
)

user = User.create(
  email: 'with_notifications@inyova.com',
  password: 'inyova1',
  password_confirmation: 'inyova1',
  device_token: SecureRandom.hex(8)
)

user.notifications << notification_past
user.notifications << notification_today
user.notifications << notification_future

User.create(
  email: 'without_notifications@inyova.com',
  password: 'inyova1',
  password_confirmation: 'inyova1',
  device_token: SecureRandom.hex(8)
)

User.create(
  email: 'admin@inyova.com',
  admin: true,
  password: 'inyova1',
  password_confirmation: 'inyova1',
  device_token: SecureRandom.hex(8)
)

notification_today = Notification.create(
  title: 'New ticker is available: UBSG',
  description: 'Rich description of the UBSG ticker',
  date: Date.today
)

(0..50).each do |i|
  user = User.create(
    email: "test#{i}@inyova.com",
    password: 'inyova1',
    password_confirmation: 'inyova1',
    device_token: SecureRandom.hex(8)
  )

  notification_today.users << user
end

# To schedule notification_today run in rails console:
# Notifications::SchedulingService.new(Notification.last).call
