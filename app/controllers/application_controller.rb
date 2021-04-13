# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :configure_permitted_parameters, if: :devise_controller?

  def check
    render json: { status: "OK", version: ENV["SHA"], environment: Rails.env }, status: :ok
  end

  def after_sign_in_path_for(user)
    stored_location_for(user) || login_dashboard_path(user)
  end

protected

  def login_dashboard_path(user)
    if user.account_created
      dashboard_path
    else
      new_username_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email full_name])
  end
end
