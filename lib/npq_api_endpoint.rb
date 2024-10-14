# frozen_string_literal: true

class NpqApiEndpoint
  def self.matches?(_request)
    !disabled?
  end

  def self.disabled?
    FeatureFlag.active?(:disable_npq)
  end
end
