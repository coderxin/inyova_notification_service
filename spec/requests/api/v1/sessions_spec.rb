# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/sessions', type: :request do
  let(:password) { 'password123' }
  let!(:user) { create(:user, password:, password_confirmation: password) }

  describe 'POST #create' do
    context 'when authentication is successful' do
      before do
        post api_v1_sessions_url,
             params: { email: user.email, password: },
             as: :json
      end

      it do
        expect(response).to be_successful
        expect(response_json['data'].keys.sort).to eq(
          ['access', 'access_expires_at', 'csrf', 'refresh', 'refresh_expires_at']
        )
      end
    end
  end
end
