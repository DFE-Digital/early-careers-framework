# frozen_string_literal: true

class LeadProviderRequestAuditor
  def initialize(app)
    @app = app
  end

  def call(env)
    store_request_details(env)
    @app.call(env)
  end

private

  def store_request_details(env)
    path = env["PATH_INFO"]
    if audited_paths.any? { |pattern| pattern.match?(path) }
      request = Rack::Request.new(env)
      body = request.body.read.squish
      ApiRequestAudit.create!(path: path, body: body)
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  def audited_paths
    [/\/api\/v1\/participant-declarations/]
  end
end
