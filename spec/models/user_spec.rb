# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to have_secure_password }

  it { is_expected.to have_many(:notification_assignments).dependent(:destroy) }
  it { is_expected.to have_many(:notifications) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
end
