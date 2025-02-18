# frozen_string_literal: true

class SessionRestoreErrorRescueMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionDispatch::Session::SessionRestoreError
    req = ActionDispatch::Request.new(env)
    session_id = req.cookies[session_key]
    private_id = Rack::Session::SessionId.new(session_id).private_id
    ActiveRecord::SessionStore::Session.where(session_id: private_id).delete_all

    @app.call(req.env)
  end

  def session_key
    Rails.application.config.session_options[:key]
  end
end
