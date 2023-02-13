# frozen_string_literal: true

class HandleNotifyCallbackJob < ApplicationJob
  def perform(email_id:, delivery_status:, sent_at:)
    mail = PartnershipNotificationEmail.find_by(notify_id: email_id) || NominationEmail.find_by(notify_id: email_id)
    mail.update!(notify_status: delivery_status, delivered_at: sent_at) if mail

    Email.find(email_id).update!(status: delivery_status, delivered_at: sent_at)
  end
end
