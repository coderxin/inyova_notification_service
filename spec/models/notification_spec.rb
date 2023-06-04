# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to have_many(:notification_assignments).dependent(:destroy) }
  it { is_expected.to have_many(:users) }

  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:description) }

  describe '.actual' do
    let!(:notification_today) { create(:notification) }
    let!(:notification_past) { create(:notification, :in_the_past) }
    let!(:notification_future) { create(:notification, :in_the_future) }

    it { expect(described_class.actual).to include(notification_today) }
    it { expect(described_class.actual).to include(notification_past) }
    it { expect(described_class.actual).not_to include(notification_future) }
  end

  describe '.before' do
    let!(:notification) { create(:notification, date: Time.zone.today) }

    context 'when notification date is in greater than given date' do
      it { expect(described_class.before(Time.zone.today - 1.day)).to be_empty }
    end

    context 'when notification date is in less than given date' do
      it { expect(described_class.before(Time.zone.today + 1.day)).to include(notification) }
    end

    context 'when notification date same as the given date' do
      it { expect(described_class.before(Time.zone.today)).to include(notification) }
    end
  end
end
