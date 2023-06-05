# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushNotificationJob, type: :job do
  include ActiveJob::TestHelper

  describe '.perform' do
    subject(:job) { described_class.perform_later(push_notification.id) }

    let!(:notification) { create(:notification) }
    let!(:user) { create(:user) }
    let!(:push_notification) { create(:push_notification, notification:, user:) }

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is in default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end

    it 'handles third party service error' do
      allow(MockPushService).to receive(:send).and_raise(MockPushService::Error)

      # rubocop:disable RSpec/AnyInstance
      perform_enqueued_jobs do
        expect_any_instance_of(described_class)
          .to receive(:retry_job).with(wait: 5.minutes, queue: :default)

        job
      end
      # rubocop:enable RSpec/AnyInstance

      expect(push_notification.reload.state).to eq('errored')
    end

    context 'when push notification is scheduled' do
      it do
        allow(MockPushService)
          .to receive(:send)
          .with(
            title: notification.title,
            description: notification.description,
            token: user.device_token
          )

        perform_enqueued_jobs { job }

        expect(MockPushService).to have_received(:send)
        expect(push_notification.reload.state).to eq('delivered')
      end
    end

    context 'when push notification is errored' do
      let!(:push_notification) { create(:push_notification, :errored, notification:, user:) }

      it do
        allow(MockPushService)
          .to receive(:send)
          .with(
            title: notification.title,
            description: notification.description,
            token: user.device_token
          )

        perform_enqueued_jobs { job }

        expect(MockPushService).to have_received(:send)
        expect(push_notification.reload.state).to eq('delivered')
      end
    end

    context 'when push notification is delivered' do
      let!(:push_notification) { create(:push_notification, :delivered, notification:, user:) }

      it do
        allow(MockPushService).to receive(:send)

        perform_enqueued_jobs { job }

        expect(MockPushService).not_to have_received(:send)
        expect(push_notification.reload.state).to eq('delivered')
      end
    end
  end
end
