# frozen_string_literal: true

# rubocop:disable Lint/PercentStringArray
SecureHeaders::Configuration.default do |config|
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "0"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]

  google_analytics = %w[*.google-analytics.com ssl.google-analytics.com *.googletagmanager.com tagmanager.google.com *.googleusercontent.com *.gstatic.com]

  zendesk = %w[
    https://static.zdassets.com
    https://ekr.zdassets.com
    https://ekr.zendesk.com
    https://teachercpdhelp.zendesk.com
    https://*.zopim.com
    https://zendesk-eu.my.sentry.io
    wss://teachercpdhelp.zendesk.com
    wss://*.zopim.com
  ]

  zendesk_img = %w[
    https://v2assets.zopim.io
    https://static.zdassets.com
    data:
  ]

  config.csp = SecureHeaders::OPT_OUT

  config.csp_report_only = {
    default_src: %w['none'] + zendesk,
    base_uri: %w['self'],
    block_all_mixed_content: true, # see http://www.w3.org/TR/mixed-content/
    child_src: %w['self'],
    connect_src: %W['self' *.ingest.sentry.io] + google_analytics + zendesk,
    font_src: %w['self' *.gov.uk fonts.gstatic.com],
    form_action: %w['self'],
    frame_ancestors: %w['self'],
    frame_src: %w['self'] + google_analytics,
    img_src: %W['self' data: *.gov.uk online.swagger.io validator.swagger.io] + google_analytics + zendesk_img,
    manifest_src: %w['self'],
    media_src: %w['self'],
    script_src: %W['self' 'unsafe-inline' 'unsafe-eval' *.gov.uk] + google_analytics + zendesk,
    style_src: %w['self' 'unsafe-inline' *.gov.uk fonts.googleapis.com] + google_analytics,
    worker_src: %w['self'],
    # upgrade_insecure_requests: !Rails.env.development?, # see https://www.w3.org/TR/upgrade-insecure-requests/
    report_uri: %w[/csp_reports],
  }
end
# rubocop:enable Lint/PercentStringArray
