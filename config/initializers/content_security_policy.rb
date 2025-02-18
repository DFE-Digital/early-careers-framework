# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  # Default policy for the application; covers static pages and the
  # admin/finance dashboards.
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, :blob, "https://www.googletagmanager.com/td"
    policy.object_src  :none
    policy.script_src  :self, "https://www.googletagmanager.com/gtm.js", "https://www.googletagmanager.com/gtag/js", "https://static.zdassets.com/ekr/snippet.js"
    policy.style_src   :self
    policy.connect_src :self, "*.google-analytics.com"
    policy.frame_src   :self, "https://www.googletagmanager.com/ns.html"

    # I haven't figured out why yet, but a couple of the feature tests
    # fail when this is set; its very strange.
    policy.report_uri  "/csp_reports" unless Rails.env.test?
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(_) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = true

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
