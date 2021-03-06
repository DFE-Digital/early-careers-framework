# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :previous_url_for_cookies_page, except: :check
  before_action :check_privacy_policy_accepted, except: :check
  before_action :set_sentry_user, except: :check, unless: :devise_controller?

  def check
    head :ok
  end

private

  def previous_url_for_cookies_page
    if request.get? && controller_name == "cookies"
      session[:return_to] ||= root_url
    elsif request.get?
      session[:return_to] = request.original_url
    end
  end

  def after_sign_in_path_for(user)
    stored_location_for(user) || helpers.profile_dashboard_path(user)
  end

  def after_sign_out_path_for(_user)
    users_signed_out_path
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

  def check_privacy_policy_accepted
    return if current_user.blank?

    policy = PrivacyPolicy.current
    return if policy.nil?

    return if request.format.json?

    return unless policy.acceptance_required?(current_user)

    session[:original_path] = request.fullpath
    redirect_to privacy_policy_path
  end

  def set_sentry_user
    return if current_user.blank?

    Sentry.set_user(id: current_user.id)
  end
end
