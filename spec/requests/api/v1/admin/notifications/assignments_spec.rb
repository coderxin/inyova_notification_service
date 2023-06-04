# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/admin/v1/notifications/:id/assignments', type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_headers) do
    {
      'Authorization' => "Bearer #{auth_token_for(admin)}"
    }
  end

  describe 'GET /index' do
    let(:notification) { create(:notification) }

    context 'when request is authenticated' do
      it 'renders a successful empty response' do
        get api_v1_admin_notification_assignments_url(notification),
            headers: valid_headers,
            as: :json

        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(response_json).to eq({ 'data' => [] })
      end

      it 'renders a successful non-empty response' do
        user1 = create(:user)
        notification_assignment1 = create(:notification_assignment, notification:, user: user1)

        user2 = create(:user)
        notification_assignment2 = create(:notification_assignment, :seen, notification:, user: user2)

        get api_v1_admin_notification_assignments_url(notification),
            headers: valid_headers,
            as: :json

        expect(response).to be_successful
        expect(response_json).to eq({
                                      'data' => [
                                        {
                                          'id' => notification_assignment2.id,
                                          'user_id' => notification_assignment2.user_id,
                                          'seen_at' => notification_assignment2.seen_at.iso8601(3),
                                          'created_at' => notification_assignment2.created_at.iso8601(3),
                                          'updated_at' => notification_assignment2.updated_at.iso8601(3)
                                        },
                                        {
                                          'id' => notification_assignment1.id,
                                          'user_id' => notification_assignment1.user_id,
                                          'seen_at' => nil,
                                          'created_at' => notification_assignment1.created_at.iso8601(3),
                                          'updated_at' => notification_assignment1.updated_at.iso8601(3)
                                        }
                                      ]
                                    })
      end
    end

    context 'when request is not authenticated' do
      it 'renders an unsuccessful response' do
        get api_v1_admin_notification_assignments_url(notification),
            headers: {},
            as: :json

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
        get api_v1_admin_notification_assignments_url(notification),
            headers: valid_headers,
            as: :json

        expect(response.status).to eq(403)
        expect(response_json).to eq({ 'error' => 'Not authorized as an Admin user.' })
      end
    end
  end

  describe 'POST /create' do
    let(:notification) { create(:notification) }

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    context 'when request is authorized' do
      context 'when new notification assignments are created' do
        it do
          post api_v1_admin_notification_assignments_url(notification),
               params: {
                 assignment: {
                   user_ids: [user1.id, user2.id]
                 }
               },
               headers: valid_headers,
               as: :json

          notification_assignment2 = NotificationAssignment.find_by(notification:, user: user2)
          notification_assignment1 = NotificationAssignment.find_by(notification:, user: user1)

          expect(response.status).to eq(201)
          expect(response_json).to eq({
                                        'data' => [
                                          {
                                            'id' => notification_assignment1.id,
                                            'notification_id' => notification.id,
                                            'user_id' => user1.id,
                                            'seen_at' => notification_assignment1.seen_at,
                                            'created_at' => notification_assignment1.created_at.iso8601(3),
                                            'updated_at' => notification_assignment1.updated_at.iso8601(3)
                                          },
                                          {
                                            'id' => notification_assignment2.id,
                                            'notification_id' => notification.id,
                                            'user_id' => user2.id,
                                            'seen_at' => notification_assignment2.seen_at,
                                            'created_at' => notification_assignment2.created_at.iso8601(3),
                                            'updated_at' => notification_assignment2.updated_at.iso8601(3)
                                          }
                                        ]
                                      })
        end
      end

      context 'when some notification assignments already exist' do
        it do
          create(:notification_assignment, notification:, user: user2)

          post api_v1_admin_notification_assignments_url(notification),
               params: {
                 assignment: {
                   user_ids: [user1.id, user2.id]
                 }
               },
               headers: valid_headers,
               as: :json

          notification_assignment = NotificationAssignment.find_by(notification:, user: user1)

          expect(response.status).to eq(207)
          expect(response_json).to eq({
                                        'data' => [
                                          {
                                            'id' => notification_assignment.id,
                                            'notification_id' => notification.id,
                                            'user_id' => user1.id,
                                            'seen_at' => notification_assignment.seen_at,
                                            'created_at' => notification_assignment.created_at.iso8601(3),
                                            'updated_at' => notification_assignment.updated_at.iso8601(3)
                                          }
                                        ],
                                        'errors' => ["User ID##{user2.id} has notification ID##{notification.id} already assigned"]
                                      })
        end
      end

      context 'when new notification assignments already exist' do
        it do
          create(:notification_assignment, notification:, user: user1)
          create(:notification_assignment, notification:, user: user2)

          post api_v1_admin_notification_assignments_url(notification),
               params: {
                 assignment: {
                   user_ids: [user1.id, user2.id]
                 }
               },
               headers: valid_headers,
               as: :json

          expect(response.status).to eq(400)
          expect(response_json).to eq({
                                        'errors' => [
                                          "User ID##{user1.id} has notification ID##{notification.id} already assigned",
                                          "User ID##{user2.id} has notification ID##{notification.id} already assigned"
                                        ]
                                      })
        end
      end

      context 'when new no users are given' do
        it do
          post api_v1_admin_notification_assignments_url(notification),
               params: {
                 assignment: {
                   user_ids: []
                 }
               },
               headers: valid_headers,
               as: :json

          expect(response.status).to eq(400)
          expect(response_json).to eq({
                                        'error' => 'Please provide at least one User to be assigned.'
                                      })
        end
      end
    end

    context 'when request is not authorized' do
      let(:valid_headers) do
        user = create(:user)

        {
          'Authorization' => "Bearer #{auth_token_for(user)}"
        }
      end

      it 'renders an unsuccessful response' do
        post api_v1_admin_notification_assignments_url(notification),
             params: {
               assignment: {
                 user_ids: [1, 2, 3, 4, 5]
               }
             },
             headers: valid_headers,
             as: :json

        expect(response.status).to eq(403)
        expect(response_json).to eq({ 'error' => 'Not authorized as an Admin user.' })
      end
    end
  end
end
