# frozen_string_literal: true

class HandleNotifyCallbackJob < ApplicationJob
  def perform(email_id:, delivery_status:, sent_at:, template_id:)
    mail = PartnershipNotificationEmail.find_by(notify_id: email_id) || NominationEmail.find_by(notify_id: email_id)
    mail.update!(notify_status: delivery_status, delivered_at: sent_at) if mail

    email = Email.find_by(id: email_id)

    if email.present?
      email.update!(status: delivery_status, delivered_at: sent_at)
    else
      Rails.logger.warn("Email could not be found - email_id: #{email_id}, delivery_status: #{delivery_status}, sent_at: #{sent_at}, template_id: #{template_id}")
    end
  end
end
