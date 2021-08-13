# frozen_string_literal: true

module ApiAuditable
  extend ActiveSupport::Concern

  included do
    before_action :capture_params
  end

private

  def capture_params
    ApiRequestAudit.create!(path: request.env["PATH_INFO"], body: params)
  end
end
