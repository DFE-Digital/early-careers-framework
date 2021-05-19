# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials.SENTRY_DSN
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.release = "#{ENV['RELEASE_VERSION']}-#{ENV['SHA']}"

  config.async = lambda do |event, hint|
    Sentry::SendEventJob.perform_later(event, hint)
  end

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
    # use Rails' parameter filter to sanitize the event
    filter.filter(event.to_hash)
  end

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
        0.1
      end
    else
      0.0 # We don't care about performance of other things
    end
  end
end
