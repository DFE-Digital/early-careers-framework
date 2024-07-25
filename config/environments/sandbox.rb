# frozen_string_literal: true

require Rails.root.join("config/environments/production")

Rails.application.configure do
  # Used to handle HTTP_X_WITH_SERVER_DATE header for server side datetime overwrite
  config.middleware.use TimeTraveler
end
