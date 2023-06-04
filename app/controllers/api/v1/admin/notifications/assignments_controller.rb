# frozen_string_literal: true

module Api
  module V1
    module Admin
      module Notifications
        class AssignmentsController < BaseController
          before_action :set_notification, only: %i[index create]
          before_action :validate_params, only: :create

          def index
            @notification_assignments = @notification.notification_assignments.order(created_at: :desc)
          end

          def create
            notification_assignment_service = ::Notifications::AssignmentService.new(@notification, permitted_params[:user_ids])
            notification_assignment_service.call

            if notification_assignment_service.partial_failure?
              render json: {
                data: notification_assignment_service.results,
                errors: notification_assignment_service.error_messages
              }, status: :multi_status
            elsif notification_assignment_service.failure?
              render json: {
                errors: notification_assignment_service.error_messages
              }, status: :bad_request
            elsif notification_assignment_service.success?
              render json: {
                data: notification_assignment_service.results
              }, status: :created
            end
          end

          private

          def set_notification
            @notification = Notification.find(params[:notification_id])
          end

          def validate_params
            return if permitted_params[:user_ids].present?

            render json: { error: 'Please provide at least one User to be assigned.' }, status: :bad_request
          end

          def permitted_params
            params.require(:assignment).permit(user_ids: [])
          end
        end
      end
    end
  end
end
