# frozen_string_literal: true

module RelaxedContentSecurityPolicy
  extend ActiveSupport::Concern

  included do
    include ActionController::ContentSecurityPolicy

    # More relaxad policy specific for some pages that requires inline javascripts to run
    content_security_policy do |policy|
      script_src = policy.script_src || %i[self]
      policy.script_src_elem(*script_src.concat(["'unsafe-inline'"]))
      policy.script_src_attr(*script_src.concat(["'unsafe-inline'"]))
    end
  end
end
