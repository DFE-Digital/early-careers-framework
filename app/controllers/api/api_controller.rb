# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    include ActionController::MimeResponds
    before_action :remove_charset
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :missing_parameter_response

  private

    def not_found
      head :not_found
    end

    def remove_charset
      ActionDispatch::Response.default_charset = nil
    end

    def missing_parameter_response(exception)
      render json: { missing_parameters: exception.param }, status: :unprocessable_entity
    end
  end
end
