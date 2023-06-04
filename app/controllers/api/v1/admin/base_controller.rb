# frozen_string_literal: true

module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :verify_authorisation

        private

        def verify_authorisation
          return if current_user.admin?

          render json: { error: 'Not authorized as an Admin user.' }, status: :forbidden
        end
      end
    end
  end
end
