# frozen_string_literal: true

module Notifications
  class AssignmentService
    include ActiveModel::Validations

    attr_accessor :results

    def initialize(notification, user_ids)
      @notification = notification
      @user_ids = user_ids
      @results = []
    end

    def call
      fetch_users(user_ids).each do |user|
        begin
          notification_assignment = NotificationAssignment.create!(notification: notification, user: user)
          results << notification_assignment
        rescue ActiveRecord::RecordNotUnique => e
          errors.add(:base, "User ID##{user.id} has notification ID##{notification.id} already assigned")
        end
      end

      results
    end

    def partial_failure?
      errors.present? && results.present?
    end

    def failure?
      errors.present? && results.blank?
    end

    def success?
      errors.blank? && (results.present? || results.blank?)
    end

    def error_messages
      errors[:base]
    end

    private

    attr_reader :notification, :user_ids

    def fetch_users(user_ids)
      User.where(id: user_ids)
    end
  end
end
