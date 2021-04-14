# frozen_string_literal: true

class PartnershipNotificationService
  def notify(partnership)
    notification_email = PartnershipNotificationEmail.create!(
      token: generate_token,
      sent_to: partnership.school.contact_email,
      partnership: partnership,
    )

    send_notification_email(notification_email)
  end

private

  def generate_token
    loop do
      value = SecureRandom.hex(16)
      break value unless PartnershipNotificationEmail.exists?(token: value)
    end
  end

  def send_notification_email(notification_email)
    notify_id = SchoolMailer.send_partnership_notification_email(
      recipient: notification_email.sent_to,
      provider_name: provider_name(notification_email),
      start_url: Rails.application.routes.url_helpers.root_url(host: Rails.application.config.domain),
      challenge_url: challenge_url(notification_email.token),
    )

    notification_email.update!(notify_id: notify_id)
  end

  def provider_name(notification_email)
    notification_email.delivery_partner&.name || notification_email.lead_provider.name
  end

  def challenge_url(token)
    Rails.application.routes.url_helpers.root_url( # TODO: ECF-RP-480: Update path when exists
      token: token,
      host: Rails.application.config.domain,
    )
  end
end
