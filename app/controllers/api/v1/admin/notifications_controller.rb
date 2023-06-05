# frozen_string_literal: true

module Api
  module V1
    module Admin
      class NotificationsController < BaseController
        before_action :set_notification, only: :show

        def index
          @notifications = Notification.order(created_at: :desc)
        end

        def show; end

        def create
          @notification = Notification.new(notification_params)

          if @notification.save
            ::Notifications::SchedulingService.new(@notification).call

            render :show, status: :created, location: [:api, :v1, :admin, @notification]
          else
            render json: { errors: @notification.errors }, status: :unprocessable_entity
          end
        end

        private

        def set_notification
          @notification = Notification.find(params[:id])
        end

        def notification_params
          params.require(:notification).permit(:date, :title, :description)
        end
      end
    end
  end
end
