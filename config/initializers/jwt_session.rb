# frozen_string_literal: true

JWTSessions.algorithm = 'HS256'
JWTSessions.signing_key = Rails.application.credentials.secret_key_base
