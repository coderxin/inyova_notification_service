# frozen_string_literal: true

json.data do
  json.array! @notifications, partial: 'notification', as: :notification
end
