# frozen_string_literal: true

require 'rails_helper'
require 'aasm/rspec'

RSpec.describe PushNotification, type: :model do
  it { is_expected.to belong_to(:notification) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_state(:scheduled) }
  it { is_expected.to transition_from(:scheduled).to(:delivered).on_event(:deliver) }
  it { is_expected.to transition_from(:errored).to(:delivered).on_event(:deliver) }
  it { is_expected.to transition_from(:scheduled).to(:errored).on_event(:fail) }
end
