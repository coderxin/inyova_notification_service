# frozen_string_literal: true

class PushNotificationJob < ApplicationJob
  queue_as :default

  rescue_from(MockPushService::Error) do
    retry_job wait: 5.minutes, queue: :default
  end

  def perform(push_notification_id)
    push_notification = PushNotification.find(push_notification_id)
    return if push_notification.delivered?

    notification = push_notification.notification
    user = push_notification.user

    begin
      MockPushService.send(
        title: notification.title,
        description: notification.description,
        token: user.device_token
      )
      push_notification.deliver
    rescue MockPushService::Error => e
      push_notification.fail(e)
      raise
    ensure
      push_notification.save
    end
  end
end
