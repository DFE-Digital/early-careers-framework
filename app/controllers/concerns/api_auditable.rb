# frozen_string_literal: true

# TODO: Remove, replaced by ApiRequestMiddleware
module ApiAuditable
  extend ActiveSupport::Concern

  included do
    before_action :capture_params
  end

private

  def capture_params
    ApiRequestAudit.create!(path: request.env["PATH_INFO"], body: request.raw_post)
  end
end
