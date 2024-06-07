# frozen_string_literal: true

class TimeTraveler
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless env.key?("HTTP_X_WITH_SERVER_DATE") && %w[development staging sandbox review test migration].include?(Rails.env)

    Timecop.travel(Time.zone.parse(env["HTTP_X_WITH_SERVER_DATE"])) do
      @app.call(env)
    end
  end
end
