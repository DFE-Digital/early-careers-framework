# frozen_string_literal: true

class TimeTraveler
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless env.key?("HTTP_X_WITH_SERVER_DATE")

    Timecop.travel(Time.zone.parse(env["HTTP_X_WITH_SERVER_DATE"])) do
      @app.call(env)
    end
  end
end
