# frozen_string_literal: true

class RedirectApiReferenceMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.path =~ /^\/api-reference(?:\/|$)/ && Rails.env.review?
      new_location = "/api-reference-without-npq#{request.path.sub('/api-reference', '')}"
      return [301, { "Location" => new_location, "Content-Type" => "text/html" }, ["Redirecting..."]]
    end

    @app.call(env)
  end
end
