# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notifications/:id/reads', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  let(:valid_headers) do
    {
      'Authorization' => "Bearer #{auth_token_for(user)}"
    }
  end

  describe 'PATCH /update' do
    let(:notification) { create(:notification) }

    context 'when request is authenticated' do
      it 'renders a successful response' do
        create(:notification_assignment, notification:, user:)

        patch api_v1_notification_reads_url(notification),
              headers: valid_headers,
              as: :json

        expect(response).to be_successful
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

      it 'updates time of the read' do
        notification_assignment = create(:notification_assignment, notification:, user:)

        freeze_time do
          expect do
            patch api_v1_notification_reads_url(notification),
                  headers: valid_headers,
                  as: :json
          end.to change { notification_assignment.reload.seen_at }.from(nil).to(Time.current)
        end
      end
    end

    context 'when request is not authenticated' do
      it 'renders an unsuccessful response' do
        patch api_v1_notification_reads_url(notification), headers: {}, as: :json

        expect(response.status).to eq(401)
        expect(response_json).to eq({ 'error' => 'Not authorized' })
      end
    end
  end
end
