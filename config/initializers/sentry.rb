# frozen_string_literal: true

Sentry.init do |config|
  config.enabled_environments = %w[production sandbox staging deployed_development]
  config.dsn = config.enabled_environments.include?(Rails.env) ? Rails.application.credentials.SENTRY_DSN : "disabled"
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.release = "#{ENV['RELEASE_VERSION']}-#{ENV['SHA']}"

  config.async = lambda do |event, hint|
    SentrySendEventJobNoRetry.perform_async(event, hint)
  end

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
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
