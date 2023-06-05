# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/admin/v1/notifications', type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_headers) do
    {
      'Authorization' => "Bearer #{auth_token_for(admin)}"
    }
  end

  describe 'GET /index' do
    context 'when request is authenticated' do
      it 'renders a successful empty response' do
        get api_v1_admin_notifications_url, headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response_json).to eq({ 'data' => [] })
      end

      it 'renders a successful non-empty response' do
        notification1 = create(:notification)
        notification2 = create(:notification)

        get api_v1_admin_notifications_url, headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response_json).to eq({
                                      'data' => [
                                        {
                                          'id' => notification2.id,
                                          'date' => notification2.date.to_s,
                                          'title' => notification2.title,
                                          'description' => notification2.description,
                                          'created_at' => notification2.created_at.iso8601(3),
                                          'updated_at' => notification2.updated_at.iso8601(3)
                                        },
                                        {
                                          'id' => notification1.id,
                                          'date' => notification1.date.to_s,
                                          'title' => notification1.title,
                                          'description' => notification1.description,
                                          'created_at' => notification1.created_at.iso8601(3),
                                          'updated_at' => notification1.updated_at.iso8601(3)
                                        }
                                      ]
                                    })
      end
    end

    context 'when request is not authenticated' do
      it 'renders an unsuccessful response' do
        get api_v1_admin_notifications_url, headers: {}, as: :json

        expect(response.status).to eq(401)
        expect(response_json).to eq({ 'error' => 'Not authorized' })
      end
    end

    context 'when request is not authorized' do
      let(:user) { create(:user) }

      let(:valid_headers) do
        {
          'Authorization' => "Bearer #{auth_token_for(user)}"
        }
      end

      it 'renders an unsuccessful response' do
        get api_v1_admin_notifications_url, headers: valid_headers, as: :json

        expect(response.status).to eq(403)
        expect(response_json).to eq({ 'error' => 'Not authorized as an Admin user.' })
      end
    end
  end

  describe 'POST /create' do
    context 'when request is authenticated' do
      context 'with valid parameters' do
        it 'creates a new Notification' do
          expect do
            post api_v1_admin_notifications_url,
                 params: {
                   notification: {
                     title: 'My notification',
                     description: 'Text',
                     date: '2023-12-12'
                   }
                 },
                 headers: valid_headers,
                 as: :json
          end.to change(Notification, :count).by(1)
        end

        it 'renders a JSON response with the new notification' do
          allow(Notifications::SchedulingService).to receive(:new).and_call_original

          post api_v1_admin_notifications_url,
               params: {
                 notification: {
                   title: 'My notification 2',
                   description: 'Text 2',
                   date: '2023-12-12'
                 }
               },
               headers: valid_headers,
               as: :json

          notification = Notification.last

          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
          expect(response_json).to eq({
                                        'data' => {
                                          'id' => notification.id,
                                          'date' => '2023-12-12',
                                          'title' => 'My notification 2',
                                          'description' => 'Text 2',
                                          'created_at' => notification.created_at.iso8601(3),
                                          'updated_at' => notification.updated_at.iso8601(3)
                                        }
                                      })

          expect(Notifications::SchedulingService).to have_received(:new).with(notification)
        end
      end
    end

    context 'when request is not authenticated' do
      it 'renders an unsuccessful response' do
        post api_v1_admin_notifications_url,
             params: {
               notification: {
                 title: 'My notification',
                 description: 'Text',
                 date: '2023-12-12'
               }
             },
             headers: {},
             as: :json

        expect(response.status).to eq(401)
        expect(response_json).to eq({ 'error' => 'Not authorized' })
      end
    end
  end

  describe 'GET /show' do
    context 'when request is authenticated' do
      context 'when notification is not assigned to current user' do
        it 'renders an unsuccessful response' do
          get api_v1_admin_notification_url(123), headers: valid_headers, as: :json

          expect(response.status).to eq(404)
          expect(response_json).to eq({ 'error' => 'Not Found' })
        end
      end

      context 'when notification is assigned to current user' do
        it 'renders a successful response' do
          notification = create(:notification)

          get api_v1_admin_notification_url(notification), headers: valid_headers, as: :json

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
        get api_v1_admin_notification_url(1), headers: {}, as: :json

        expect(response.status).to eq(401)
        expect(response_json).to eq({ 'error' => 'Not authorized' })
      end
    end
  end
end
