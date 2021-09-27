# frozen_string_literal: true

class Api::NotifyCallbacksController < Api::ApiController
  def create
    return head :no_content unless params[:id]

    log_email if failed_email?

    # TODO: Replace PartnershipNotificationEmail and NominationEmail with more generic Email
    mail = PartnershipNotificationEmail.find_by(notify_id: params[:id]) || NominationEmail.find_by(notify_id: params[:id])
    mail.update!(notify_status: params[:status], delivered_at: params[:sent_at]&.to_datetime) if mail

    Email.where(id: params[:id]).update_all(
      status: params[:status],
      delivered_at: params[:sent_at],
    )

    head :no_content
  end

private

  def log_email
    Rails.logger.warn "Email could not be sent - notify_id: #{params[:id]}, reference: #{params[:reference]}, template_id: #{params[:template_id]}"
  end

  def failed_email?
    params[:status] != "sending" && params[:status] != "delivered"
  end
end
