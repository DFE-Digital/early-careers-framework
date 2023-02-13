# frozen_string_literal: true

class Api::NotifyCallbacksController < Api::ApiController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate, if: -> { Rails.application.credentials.notify_callback_token.present? }

  def create
    return head :no_content unless params[:id]

    log_email if failed_email?

    HandleNotifyCallbackJob.perform_later(email_id: params[:id], delivery_status: params[:status], sent_at: params[:sent_at])

    head :no_content
  end

private

  def log_email
    Rails.logger.warn "Email could not be sent - notify_id: #{params[:id]}, reference: #{params[:reference]}, template_id: #{params[:template_id]}"
  end

  def failed_email?
    params[:status] != "sending" && params[:status] != "delivered"
  end

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.credentials.notify_callback_token)
    end
  end
end
