# frozen_string_literal: true

class Nominations::NotifyCallbacksController < ActionController::API
  def create
    return head :no_content unless params[:reference]

    email = NominationEmail.find_by(token: params[:reference])
    email.update!(notify_status: params[:status]) if email
    log_email if failed_email?(email)

    head :no_content
  end

private

  def log_email
    Rails.logger.info "Email could not be sent"
    Rails.logger.info "notify_id: #{params[:id]}"
    Rails.logger.info "reference: #{params[:reference]}"
    Rails.logger.info "template_id: #{params[:template_id]}"
  end

  def failed_email?(email)
    return false if email.nil?

    params[:status] != "sending" && params[:status] != "delivered"
  end
end
