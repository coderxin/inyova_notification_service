# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifications::SchedulingService, type: :service do
  let(:service) { described_class.new(notification) }

  describe '.call' do
    subject(:call) { service.call }

    let!(:notification) { create(:notification) }

    it do
      job = class_double('ScheduledNotificationJob')
      allow(job).to receive(:perform_later).with(notification.id)

      allow(ScheduledNotificationJob).to receive(:set).with(wait_until: notification.date.to_datetime).and_return(job)

      call

      expect(job).to have_received(:perform_later)
    end
  end
end
