# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  # Default policy for the application; covers static pages and the
  # admin/finance dashboards.
  self_base          = %i[self]
  data               = %i[data]
  blob               = %i[blob]
  gtm_src            = %w[*.googletagmanager.com www.googletagmanager.com]
  ga_connect_src     = %w[*.google-analytics.com]
  zd_script_src      = %w[*.zdassets.com]
  gfonts_src         = %w[fonts.gstatic.com *.fonts.gstatic.com]
  sentry_connect_src = %w[*.ingest.sentry.io]

  config.content_security_policy do |policy|
    policy.default_src(*self_base)
    policy.font_src(*self_base.concat(data, gfonts_src))
    policy.img_src(*self_base.concat(data, blob, gtm_src))
    policy.object_src :none
    policy.script_src(*self_base.concat(gtm_src, zd_script_src, ["'unsafe-eval'"]))
    policy.style_src(*self_base.concat(gfonts_src))
    policy.connect_src(*self_base.concat(ga_connect_src, zd_script_src, sentry_connect_src))
    policy.frame_src(*self_base.concat(gtm_src))
    policy.style_src_elem(*self_base.concat(["'unsafe-inline'"]))
    policy.style_src_attr(*self_base.concat(["'unsafe-inline'"]))

    # The report-uri seems to make the feature specs flakey when ran in
    # CI. I'm not sure why - disabling for now.
    policy.report_uri "/csp_reports" unless Rails.env.test?
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(_) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = false

  # Security-related HTTP headers.
  config.action_dispatch.default_headers = {
    "X-Frame-Options" => "DENY",
    "X-XSS-Protection" => "0",
    "X-Content-Type-Options" => "nosniff",
    "X-Permitted-Cross-Domain-Policies" => "none",
    "Referrer-Policy" => "origin-when-cross-origin, strict-origin-when-cross-origin",
    "X-Download-Options" => "noopen",
  }
end
