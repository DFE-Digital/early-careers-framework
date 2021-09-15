# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    include ActionController::MimeResponds
    before_action :remove_charset
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :missing_parameter_response
    rescue_from ActionController::UnpermittedParameters, with: :unpermitted_parameter_response
    rescue_from ActionController::BadRequest, with: :bad_request_response
    rescue_from ActiveRecord::StatementInvalid, with: :bad_request_response
    rescue_from ArgumentError, with: :bad_request_response
    rescue_from ActiveRecord::RecordNotUnique, with: :bad_request_response
    rescue_from ActiveRecord::RecordInvalid, with: :invalid_transition
    rescue_from InvalidTransitionError, with: :invalid_transition

  private

    def not_found
      head :not_found
    end

    def remove_charset
      ActionDispatch::Response.default_charset = nil
    end

    def missing_parameter_response(exception)
      render json: { errors: Api::ParamErrorFactory.new(error: "Bad or missing parameters", params: exception.param).call }, status: :unprocessable_entity
    end

    def unpermitted_parameter_response(exception)
      render json: { errors: Api::ParamErrorFactory.new(error: "Unpermitted parameters", params: exception.params).call }, status: :unprocessable_entity
    end

    def bad_request_response(exception)
      render json: { errors: Api::ParamErrorFactory.new(error: "Bad request", params: exception.message).call }, status: :bad_request
    end

    def invalid_transition(exception)
      render json: { errors: Api::ParamErrorFactory.new(error: "Invalid action", params: exception).call }, status: :unprocessable_entity
    end
  end
end
