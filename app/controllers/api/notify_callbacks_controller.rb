# frozen_string_literal: true

class Api::NotifyCallbacksController < Api::ApiController
  def create
    return head :no_content unless params[:reference] || params[:id]

    if params[:reference]
      email = NominationEmail.find_by(token: params[:reference])
      email.update!(notify_status: params[:status]) if email
    else
      email = PartnershipNotificationEmail.find_by(notify_id: params[:id])
      email.update!(notify_status: params[:status], delivered_at: params[:sent_at]&.to_datetime) if email
    end

    log_email if failed_email?(email)

    head :no_content
  end

private

  def log_email
    Rails.logger.info "Email could not be sent - notify_id: #{params[:id]}, reference: #{params[:reference]}, template_id: #{params[:template_id]}"
  end

  def failed_email?(email)
    return false if email.nil?

    params[:status] != "sending" && params[:status] != "delivered"
  end
end
