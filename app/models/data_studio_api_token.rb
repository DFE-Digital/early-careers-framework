# frozen_string_literal: true

class DataStudioApiToken < ApiToken
  attribute :private_api_access, default: true

  def owner
    "Data Studio"
  end

  def owner_description
    owner
  end
end
