# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notifications', type: :request do
  let(:user) { create(:user) }

  let(:valid_headers) do
    {
      'Authorization' => "Bearer #{auth_token_for(user)}"
    }
  end

  describe 'GET /index' do
    context 'when request is authenticated' do
      it 'renders a successful empty response' do
        get api_v1_notifications_url, headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response_json).to eq({ 'data' => [] })
      end

      it 'renders a successful non-empty response' do
        notification_in_the_future = create(:notification, :in_the_future)
        notification = create(:notification)

        create(:notification_assignment, notification: notification_in_the_future, user:)
        create(:notification_assignment, notification:, user:)

        get api_v1_notifications_url, headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response_json).to eq({
                                      'data' => [
                                        {
                                          'id' => notification.id,
                                          'date' => notification.date.to_s,
                                          'title' => notification.title,
                                          'description' => notification.description,
                                          'created_at' => notification.created_at.iso8601(3),
                                          'updated_at' => notification.updated_at.iso8601(3)
                                        }
                                      ]
                                    })
      end
    end

    context 'when request is not authenticated' do
      it 'renders an unsuccessful response' do
        get api_v1_notifications_url, headers: {}, as: :json

        expect(response.status).to eq(401)
        expect(response_json).to eq({ 'error' => 'Not authorized' })
      end
    end
  end

  describe 'GET /show' do
    context 'when request is authenticated' do
      context 'when notification is not assigned to current user' do
        it 'renders a successful response' do
          notification = create(:notification)

          get api_v1_notification_url(notification), headers: valid_headers, as: :json

          expect(response.status).to eq(404)
          expect(response_json).to eq({ 'error' => 'Not Found' })
        end
      end

      context 'when notification is assigned to current user' do
        it 'renders a successful response' do
          notification = create(:notification)
          create(:notification_assignment, notification:, user:)

          get api_v1_notification_url(notification), headers: valid_headers, as: :json

          expect(response.status).to eq(200)
          expect(response_json).to eq({
                                        'data' => {
                                          'id' => notification.id,
                                          'date' => notification.date.to_s,
                                          'title' => notification.title,
                                          'description' => notification.description,
                                          'created_at' => notification.created_at.iso8601(3),
                                          'updated_at' => notification.updated_at.iso8601(3)
                                        }
                                      })
        end
      end
    end

    context 'when request is not authenticated' do
      it 'renders an unsuccessful response' do
        get api_v1_notifications_url(1), headers: {}, as: :json

        expect(response.status).to eq(401)
        expect(response_json).to eq({ 'error' => 'Not authorized' })
      end
    end
  end
end
