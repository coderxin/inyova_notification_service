# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < BaseController
      before_action :set_notification, only: :show

      def index
        @notifications = notifications_scope.order(date: :desc)
      end

      def show; end

      private

      def set_notification
        @notification = notifications_scope.find(params[:id])
      end

      def notifications_scope
        current_user.notifications.actual
      end
    end
  end
end
