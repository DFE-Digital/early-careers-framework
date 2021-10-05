# frozen_string_literal: true

class PartnershipNotificationService
  def notify(partnership)
    ActiveRecord::Base.transaction do
      if partnership.school.registered?
        notification_email = create_notification_email(
          partnership,
          PartnershipNotificationEmail.email_types[:induction_coordinator_email],
        )

        coordinator_name = partnership.school.induction_coordinators.first.full_name
        send_notification_email_to_coordinator(notification_email, coordinator_name)
      else
        notification_email = create_notification_email(
          partnership,
          PartnershipNotificationEmail.email_types[:school_email],
        )

        send_notification_email_to_school(notification_email)
      end
    end
  end

  def send_reminder(partnership)
    ActiveRecord::Base.transaction do
      if partnership.school.registered?
        notification_email = create_notification_email(
          partnership,
          PartnershipNotificationEmail.email_types[:induction_coordinator_reminder_email],
        )

        coordinator_name = partnership.school.induction_coordinators.first.full_name
        send_notification_email_to_coordinator(notification_email, coordinator_name)
      else
        notification_email = create_notification_email(
          partnership,
          PartnershipNotificationEmail.email_types[:school_reminder_email],
        )

        send_notification_email_to_school(notification_email)
      end
    end
  end

  def send_invite_sit_reminder_to_partnered_schools
    current_year = Cohort.current.start_year

    School.joins(:school_cohorts)
      .partnered(current_year)
      .where(school_cohorts: { induction_programme_choice: %i[full_induction_programme] })
      .where.missing(:induction_coordinators)
      .includes(:partnerships)
      .find_each do |school|
        ActiveRecord::Base.transaction do
          partnership = school.partnerships.unchallenged.in_year(current_year).first

          notification_email = create_notification_email(
            partnership,
            PartnershipNotificationEmail.email_types[:nominate_sit_email],
          )

          nomination_email = NominationEmail.create_nomination_email(
            sent_at: notification_email.created_at,
            sent_to: notification_email.sent_to,
            school: notification_email.partnership.school,
            partnership_notification_email: notification_email,
          )

          notify_id = SchoolMailer.partnered_school_invite_sit_email(
            recipient: notification_email.sent_to,
            school_name: school.name,
            lead_provider_name: notification_email.lead_provider.name,
            delivery_partner_name: notification_email.delivery_partner.name,
            nominate_url: nomination_email.nomination_url(utm_source: :partnered_invite_sit_reminder),
            challenge_url: challenge_url(notification_email.token, utm_source: :partnered_invite_sit_reminder),
          ).deliver_now.delivery_method.response.id

          partnership.update!(challenge_deadline: 2.weeks.from_now)
          notification_email.update!(notify_id: notify_id)
        end
      end
  end

private

  def create_notification_email(partnership, type)
    PartnershipNotificationEmail.create!(
      token: generate_token,
      sent_to: partnership.school.contact_email.presence || "ecf-tech@digital.education.gov.uk",
      partnership: partnership,
      email_type: type,
    )
  end

  def generate_token
    loop do
      value = SecureRandom.hex(16)
      break value unless PartnershipNotificationEmail.exists?(token: value)
    end
  end

  def send_notification_email_to_school(notification_email)
    nomination_email = NominationEmail.create_nomination_email(
      sent_at: notification_email.created_at,
      sent_to: notification_email.sent_to,
      school: notification_email.partnership.school,
      partnership_notification_email: notification_email,
    )

    notify_id = SchoolMailer.school_partnership_notification_email(
      recipient: notification_email.sent_to,
      lead_provider_name: notification_email.lead_provider.name,
      delivery_partner_name: notification_email.delivery_partner.name,
      school_name: notification_email.school.name,
      nominate_url: nomination_email.nomination_url,
      challenge_url: challenge_url(notification_email.token),
      challenge_deadline: notification_email.challenge_deadline.strftime("%d/%m/%Y"),
    ).deliver_now.delivery_method.response.id

    notification_email.update!(notify_id: notify_id)
  end

  def send_notification_email_to_coordinator(notification_email, coordinator_name)
    notify_id = SchoolMailer.coordinator_partnership_notification_email(
      recipient: notification_email.sent_to,
      name: coordinator_name,
      lead_provider_name: notification_email.lead_provider.name,
      delivery_partner_name: notification_email.delivery_partner.name,
      school_name: notification_email.school.name,
      sign_in_url: Rails.application.routes.url_helpers.new_user_session_url(
        host: Rails.application.config.domain,
        **UTMService.email(:partnership_notification, :partnership_notification),
      ),
      challenge_url: challenge_url(notification_email.token),
      challenge_deadline: notification_email.challenge_deadline.strftime("%d/%m/%Y"),
    ).deliver_now.delivery_method.response.id

    notification_email.update!(notify_id: notify_id)
  end

  def challenge_url(token, utm_source: :challenge_partnership)
    Rails.application.routes.url_helpers.challenge_partnership_url(
      token: token,
      host: Rails.application.config.domain,
      **UTMService.email(utm_source, utm_source),
    )
  end
end
