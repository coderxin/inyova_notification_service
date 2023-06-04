# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      before_action :authorize_access_request!
    end
  end
end
