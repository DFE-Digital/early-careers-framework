# frozen_string_literal: true

class NpqApiEndpoint
  def self.matches?(_request)
    !disable_npq_endpoints?
  end

  def self.disable_npq_endpoints?
    return false unless Rails.application.config.respond_to?(:separation)

    !!(Rails.application.config.separation || {})[:disable_npq_endpoints]
  end
end
