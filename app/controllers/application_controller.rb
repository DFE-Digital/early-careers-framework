# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user, unless: :devise_controller?

  def check
    render json: { status: "OK", version: ENV["SHA"], environment: Rails.env }, status: :ok
  end

  def after_sign_in_path_for(user)
    helpers.profile_dashboard_url(user)
  end

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email full_name])
  end

  def set_current_user
    @current_user = current_user
  end
end
