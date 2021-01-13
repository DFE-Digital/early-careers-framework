# frozen_string_literal: true

class ApplicationController < ActionController::Base
  class EmailNotFoundError < StandardError; end

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user

  rescue_from EmailNotFoundError do
    render "users/sessions/email_not_found"
  end

  def check
    render json: { status: "OK", version: ENV["SHA"], environment: Rails.env }, status: :ok
  end

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email first_name last_name])
  end

  def set_current_user
    @current_user = current_user
  end
end
