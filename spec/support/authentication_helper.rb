# frozen_string_literal: true

module AuthenticationHelper
  def auth_token_for(user)
    payload = { user_id: user.id }
    session = JWTSessions::Session.new(payload:)
    session.login[:access]
  end
end
