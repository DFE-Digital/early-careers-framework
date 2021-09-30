# frozen_string_literal: true

module FeatureFlagHelper
  def and_feature_flag_is_active(flag)
    FeatureFlag.activate(flag)
  end

  alias_method :given_feature_flag_is_active, :and_feature_flag_is_active
end
