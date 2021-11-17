# frozen_string_literal: true

class PartnershipNotificationService
  def notify(partnership)
    if partnership.school.registered?
      send_notification_email_to_coordinator(partnership)
    else
      send_notification_email_to_school(partnership)
    end
  end

  def send_reminder(partnership)
    if partnership.school.registered?
      send_notification_email_to_coordinator(partnership, reminder: true)
    else
      send_notification_email_to_school(partnership, reminder: true)
    end
  end

private

  def send_notification_email_to_school(partnership, reminder: false)
    access_token = SchoolAccessToken.create!(
      school: partnership.school,
      permitted_actions: %i[nominate_tutor challenge_partnership],
    )

    SchoolMailer.school_partnership_notification_email(
      partnership: partnership,
      access_token: access_token,
      reminder: reminder,
    ).deliver_later
  end

  def send_notification_email_to_coordinator(partnership, reminder: false)
    access_token = SchoolAccessToken.create!(
      school: partnership.school,
      permitted_actions: %i[challenge_partnership],
    )

    SchoolMailer.coordinator_partnership_notification_email(
      partnership: partnership,
      access_token: access_token,
      reminder: reminder,
    ).deliver_later
  end
end
