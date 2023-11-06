# frozen_string_literal: true

class ApiRequest < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true
  scope :unprocessable_entities, -> { where(status_code: 422) }
  scope :errors, -> { where.not(status_code: [200, 302, 301]) }
  scope :successful, -> { where(status_code: [200]) }

  def send_event(type, data)
    return unless FeatureFlag.active?(:send_api_request_to_analytics)

    # exclude or only send events for specific api endpoints
    return if data["request_path"] =~ /^\/api\/v\d+\/npq-profiles/

    super
  end
end
