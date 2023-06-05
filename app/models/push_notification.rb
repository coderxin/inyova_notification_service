# frozen_string_literal: true

class PushNotification < ApplicationRecord
  include AASM

  belongs_to :notification
  belongs_to :user

  aasm column: :state do
    state :scheduled, initial: true
    state :delivered, before_enter: proc { self.delivered_at = Time.current }
    state :errored

    event :deliver do
      transitions from: [:errored, :scheduled], to: :delivered
    end

    event :fail do
      transitions from: :scheduled, to: :errored
    end
  end
end
