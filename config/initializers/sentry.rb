# frozen_string_literal: true

FILTERABLE_JS_ERRORS = [
  "Failed to fetch",
  "NetworkError when attempting to fetch resource.",
].freeze

def filterable_js_event?(event, hint)
  hint[:exception].is_a?(TypeError) && event.exception.values.any? do |exception|
    FILTERABLE_JS_ERRORS.include?(exception.value)
  end
end

Sentry.init do |config|
  config.enabled_environments = %w[production sandbox staging review]
  config.dsn = config.enabled_environments.include?(Rails.env) ? Rails.application.credentials.SENTRY_DSN : "disabled"
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.release = "#{ENV['RELEASE_VERSION']}-#{ENV['SHA']}"

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    return nil if filterable_js_event?(event, hint)

    # use Rails' parameter filter to sanitize the event
    filter.filter(event.to_hash)
  end

  config.excluded_exceptions += ["Pundit::NotAuthorizedError"]

  config.traces_sampler = lambda do |sampling_context|
    transaction_context = sampling_context[:transaction_context]
    op = transaction_context[:op]
    transaction_name = transaction_context[:name]

    case op
    when /request/
      case transaction_name
      when /check/
        0.0 # ignore healthcheck requests
      when /test_ecf_participants/
        1.0
      else
        0.01
      end
    when /sidekiq/
      0.001
    else
      0.0 # We don't care about performance of other things
    end
  end
end
