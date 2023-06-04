# frozen_string_literal: true

class Notification < ApplicationRecord
  has_many :notification_assignments, dependent: :destroy
  has_many :users, through: :notification_assignments

  validates :date, :title, :description, presence: true

  scope :actual, -> { before(Time.zone.today) }
  scope :before, ->(date) { where('date <= ?', date) }
end
