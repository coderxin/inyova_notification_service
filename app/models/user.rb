# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :notification_assignments, dependent: :destroy
  has_many :notifications, through: :notification_assignments

  validates :email, presence: true, uniqueness: true
end
