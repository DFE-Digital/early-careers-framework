# frozen_string_literal: true

class EngageAndLearnApiToken < ApiToken
  attribute :private_api_access, default: true

  def owner
    "Engage and learn application"
  end
end
