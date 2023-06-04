# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifications::AssignmentService, type: :service do
  let(:service) { described_class.new(notification, user_ids) }

  describe '.call' do
    subject(:call) { service.call }

    let!(:notification) { create(:notification) }

    context 'when no existing assignments are given' do
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }

      let(:user_ids) { [user1.id, user2.id] }

      it do
        call

        expect(service.partial_failure?).to be_falsey
        expect(service.failure?).to be_falsey
        expect(service.success?).to be_truthy
        expect(service.error_messages).to be_empty

        expect(service.results[0]).to be_kind_of(NotificationAssignment)
        expect(service.results[0].user).to eq(user1)
        expect(service.results[0].notification).to eq(notification)

        expect(service.results[1]).to be_kind_of(NotificationAssignment)
        expect(service.results[1].user).to eq(user2)
        expect(service.results[1].notification).to eq(notification)
      end
    end

    context 'when existing assignments are given' do
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }

      let(:user_ids) { [user1.id, user2.id] }

      it do
        create(:notification_assignment, user: user1, notification:)

        call

        expect(service.partial_failure?).to be_truthy
        expect(service.failure?).to be_falsey
        expect(service.success?).to be_falsey
        expect(service.error_messages).to eq(
          ["User ID##{user1.id} has notification ID##{notification.id} already assigned"]
        )

        expect(service.results[0]).to be_kind_of(NotificationAssignment)
        expect(service.results[0].user).to eq(user2)
        expect(service.results[0].notification).to eq(notification)
      end
    end

    context 'when no users are given' do
      let(:user_ids) { [] }

      it do
        call

        expect(service.partial_failure?).to be_falsey
        expect(service.failure?).to be_falsey
        expect(service.success?).to be_truthy
        expect(service.error_messages).to be_empty

        expect(service.results).to be_empty
      end
    end
  end
end
