# frozen_string_literal: true

class NPQRegistrationApiToken < ApiToken
  attribute :private_api_access, default: true

  def owner
    "npq_registration_application"
  end

  def owner_description
    "NPQ registration application"
  end
end
