# frozen_string_literal: true

class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  CSP_KEYS = %w[
    blocked-uri
    disposition
    document-uri
    effective-directive
    original-policy
    referrer
    script-sample
    status-code
    violated-directive
  ].freeze
  MAX_ENTRY_LENGTH = 2_000

  def create
    json = JSON.parse(request.body.read)
    report = (json["csp-report"] || {})
               .slice(*CSP_KEYS)
               .transform_values { |v| v.truncate(MAX_ENTRY_LENGTH) }

    trace_csp_violation(report) unless report.empty?

    head :ok
  end

private

  def trace_csp_violation(report)
    ActiveSupport::Notifications.instrument("tta.csp_violation", report)
  end
end

ActiveSupport::Notifications.subscribe "tta.csp_violation" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  report = event.payload.transform_keys(&:dasherize)

  Rails.logger.error({ "csp-report" => report })
end
