# frozen_string_literal: true

module Api
  module V1
    module Notifications
      class ReadsController < BaseController
        before_action :set_notification, only: :update

        def update
          notification_assignment = current_user.notification_assignments.find_by(notification: @notification)
          notification_assignment.update(seen_at: Time.current)

          render json: { data: @notification },
                 status: :ok,
                 location: [:api, :v1, @notification]
        end

        private

        def set_notification
          @notification = current_user.notifications.find(params[:notification_id])
        end
      end
    end
  end
end
