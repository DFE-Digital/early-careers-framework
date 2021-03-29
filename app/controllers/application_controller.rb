# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :configure_permitted_parameters, if: :devise_controller?

  def check
    render json: { status: "OK", version: release_version, sha: ENV["SHA"], environment: Rails.env }, status: :ok
  end

  def after_sign_in_path_for(user)
    stored_location_for(user) || helpers.profile_dashboard_url(user)
  end

  def set_success_message(title: "Success", heading: "", content: "")
    flash[:success] = { title: title, heading: heading, content: content }
  end

protected

  def release_version
    ENV["RELEASE_VERSION"] || "-"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email full_name])
  end
end
