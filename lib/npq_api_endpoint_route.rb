# frozen_string_literal: true

class NpqApiEndpointRoute
  def self.matches?(_request)
    !FeatureFlag.active?(:disable_npq_endpoints)
  end
end
