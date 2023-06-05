# frozen_string_literal: true

module Notifications
  class SchedulingService
    def initialize(notification)
      @notification = notification
    end

    def call
      ScheduledNotificationJob.set(wait_until: scheduled_at).perform_later(notification.id)
    end

    private

    attr_reader :notification

    def scheduled_at
      notification.date.to_datetime
    end
  end
end
