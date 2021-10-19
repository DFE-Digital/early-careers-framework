# frozen_string_literal: true

module ApiAuditable
  extend ActiveSupport::Concern

  included do
    before_action :capture_params
  end

private

  def capture_params
    ApiRequestAudit.create!(
      path: request.env["PATH_INFO"],
      body: request.raw_post,
      current_user_class: current_user&.class&.name,
      current_user_id: current_user.is_a?(String) ? current_user : current_user&.id,
    )
  end
end
