# frozen_string_literal: true

json.data do
  json.array! @notification_assignments, partial: 'notification_assignment', as: :notification_assignment
end
