# frozen_string_literal: true

class NotificationAssignmentsPending < StandardError
  def message
    'No NotificationAssigments available for Notification'
  end
end

class ScheduledNotificationJob < ApplicationJob
  queue_as :default

  rescue_from(NotificationAssignmentsPending) do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(notification_id)
    notification = Notification.find(notification_id)

    notification_assignments = notification.notification_assignments
    raise NotificationAssignmentsPending if notification_assignments.empty?

    notification_assignments.find_each do |notification_assignment|
      push_notification = PushNotification.find_or_create_by(
        notification: notification_assignment.notification,
        user: notification_assignment.user
      )

      PushNotificationJob.perform_later(push_notification.id) if push_notification.scheduled?
    end
  end
end
