# frozen_string_literal: true

class SessionRestoreErrorRescueMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionDispatch::Session::SessionRestoreError
    req = ActionDispatch::Request.new(env)
    req.cookies.delete(session_key)
    req.env.delete("rack.session")
    req.env.delete("rack.session.options")

    @app.call(req.env)
  end

  def session_key
    Rails.application.config.session_options[:key]
  end
end
