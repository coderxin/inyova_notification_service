# frozen_string_literal: true

require 'securerandom'

User.create(
  email: 'with_notifications@inyova.com',
  password: 'inyova1',
  password_confirmation: 'inyova1',
  device_token: SecureRandom.hex(8)
)

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
