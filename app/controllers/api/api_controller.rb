# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    before_action :set_jsonapi_content_type_header
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :missing_parameter_response

  private

    def not_found
      head :not_found
    end

    def set_jsonapi_content_type_header
      headers["Content-Type"] = "application/vnd.api+json"
    end

    def missing_parameter_response(exception)
      render json: { missing_parameter: exception.param }, status: :unprocessable_entity
    end
  end
end
