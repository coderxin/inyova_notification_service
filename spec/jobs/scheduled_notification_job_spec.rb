# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduledNotificationJob, type: :job do
  include ActiveJob::TestHelper

  describe '.perform' do
    subject(:job) { described_class.perform_later(notification.id) }

    let!(:notification) { create(:notification) }
    let!(:user) { create(:user) }

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

    context 'when notification_assignment does not exist' do
      it do
        allow(PushNotificationJob).to receive(:perform_later)

        # rubocop:disable RSpec/AnyInstance
        perform_enqueued_jobs do
          expect_any_instance_of(described_class)
            .to receive(:retry_job).with(wait: 5.minutes, queue: :default)

          job
        end
        # rubocop:enable RSpec/AnyInstance

        expect(PushNotificationJob).not_to have_received(:perform_later)
      end
    end

    context 'when push notification does not exist' do
      it do
        create(:notification_assignment, notification:, user:)

        perform_enqueued_jobs do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(PushNotification).to receive(:id).and_return(1234)
          # rubocop:enable RSpec/AnyInstance

          allow(PushNotificationJob).to receive(:perform_later).with(1234)

          job

          expect(PushNotificationJob).to have_received(:perform_later)
        end
      end
    end

    context 'when push notification does exist' do
      context 'when push notification is scheduled' do
        it do
          create(:notification_assignment, notification:, user:)
          push_notification = create(:push_notification, notification:, user:)

          perform_enqueued_jobs do
            allow(PushNotificationJob).to receive(:perform_later).with(push_notification.id)

            job

            expect(PushNotificationJob).to have_received(:perform_later)
          end
        end
      end

      context 'when push notification is delivered' do
        it do
          create(:notification_assignment, notification:, user:)
          create(:push_notification, :delivered, notification:, user:)

          perform_enqueued_jobs do
            allow(PushNotificationJob).to receive(:perform_later)

            job

            expect(PushNotificationJob).not_to have_received(:perform_later)
          end
        end
      end
    end
  end
end
