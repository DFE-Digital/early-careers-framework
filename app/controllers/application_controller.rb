# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  include Pagy::Backend

  impersonates :user
  prepend CurrentUser

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :previous_url_for_cookies_page, except: :check
  before_action :check_privacy_policy_accepted, except: :check
  before_action :set_sentry_user, except: :check, unless: :devise_controller?
  skip_after_action :trigger_web_request_event, only: :check

  def check
    head :ok
  end

  def append_info_to_payload(payload)
    super
    payload[:current_user_class] = current_user&.class&.name
    payload[:current_user_id] = current_user&.id
  end

private

  def previous_url_for_cookies_page
    if request.get? && controller_name == "cookies"
      session[:return_to] ||= root_url
    elsif request.get?
      session[:return_to] = request.original_url
    end
  end

  def after_sign_in_path_for(_user)
    stored_location_for(current_user) || helpers.choose_role_path
  end

  def after_sign_out_path_for(_user)
    users_signed_out_path
  end

  def set_success_message(title: "Success", heading: "", content: "")
    flash[:success] = { title:, heading:, content: }
  end

  def set_important_message(title: "Important", heading: "", content: "")
    flash[:notice] = { title:, heading:, content: }
  end

  def set_alert_message(title: "There is a problem", content: "", now: false)
    if now
      flash.now[:alert] = { title:, content: }
    else
      flash[:alert] = { title:, content: }
    end
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

    # Impersonators should not accept policies
    return if current_user != true_user

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

  def track_validation_error(form)
    ValidationError.create!(
      form_object: form.class.name,
      request_path: request.path,
      user: current_user,
      details: form.errors.messages.to_h { |field, messages| [field, { messages:, value: (form.public_send(field) if form.respond_to?(field)) }] },
    )
  rescue StandardError => e
    Rails.logger.error("validation error not saved: #{e.message}")
  end
end
