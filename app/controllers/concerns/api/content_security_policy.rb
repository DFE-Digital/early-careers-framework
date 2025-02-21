# frozen_string_literal: true

module Api::ContentSecurityPolicy
  extend ActiveSupport::Concern

  included do
    include ActionController::ContentSecurityPolicy

    # Policy for the lead provider API; we don't want to allow any external
    # resources to be loaded.
    content_security_policy do |policy|
      policy.default_src :none
      policy.font_src    :none
      policy.img_src     :none
      policy.object_src  :none
      policy.script_src  :none
      policy.style_src   :none
      policy.frame_src   :none
    end
  end
end
