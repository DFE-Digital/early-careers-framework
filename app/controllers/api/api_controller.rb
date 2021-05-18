# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    before_action :set_jsonapi_content_type_header
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

    def not_found
      head :not_found
    end

    def set_jsonapi_content_type_header
      headers["Content-Type"] = "application/vnd.api+json"
    end
  end
end
