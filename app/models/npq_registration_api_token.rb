# frozen_string_literal: true

class NpqRegistrationApiToken < ApiToken
  def owner
    "npq_registration_application"
  end
end
