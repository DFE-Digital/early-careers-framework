# frozen_string_literal: true

class PartnershipNotificationService
  def notify(partnership)
    ActiveRecord::Base.transaction do
      if partnership.school.registered?
        notification_email = create_notification_email(partnership, :induction_coordinator_email)
        coordinator = partnership.school.induction_coordinators.first
        send_notification_email_to_coordinator(notification_email, coordinator)
      else
        notification_email = create_notification_email(partnership, :school_email)
        send_notification_email_to_school(notification_email)
      end
    end
  end

  def send_reminder(partnership)
    ActiveRecord::Base.transaction do
      if partnership.school.registered?
        notification_email = create_notification_email(partnership, :induction_coordinator_reminder_email)
        coordinator = partnership.school.induction_coordinators.first
        send_notification_email_to_coordinator(notification_email, coordinator)
      else
        notification_email = create_notification_email(partnership, :school_reminder_email)
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

          notify_id = SchoolMailer.with(
            recipient: notification_email.sent_to,
            school:,
            lead_provider_name: notification_email.lead_provider.name,
            delivery_partner_name: notification_email.delivery_partner.name,
            nominate_url: nomination_email.nomination_url(utm_source: :partnered_invite_sit_reminder),
            challenge_url: challenge_url(notification_email.token, utm_source: :partnered_invite_sit_reminder),
          ).partnered_school_invite_sit_email.deliver_now.delivery_method.response.id

          # This would usually be two weeks, but we don't want providers to be able challenge after the first milestone date.
          partnership.update!(challenge_deadline: Date.parse("Oct 31 2021").end_of_day)
          notification_email.update!(notify_id:)
        end
      end
  end

private

  def create_notification_email(partnership, type)
    PartnershipNotificationEmail.create!(
      token: generate_token,
      sent_to: partnership.school.contact_email.presence || "ecf-tech@digital.education.gov.uk",
      partnership:,
      email_type: PartnershipNotificationEmail.email_types[type],
    )
  end

  def send_notification_email_to_school(notification_email)
    nomination_email = NominationEmail.create_nomination_email(
      sent_at: notification_email.created_at,
      sent_to: notification_email.sent_to,
      school: notification_email.partnership.school,
      partnership_notification_email: notification_email,
    )

    notify_id = SchoolMailer.with(
      recipient: notification_email.sent_to,
      partnership: notification_email.partnership,
      nominate_url: nomination_email.nomination_url,
      challenge_url: challenge_url(notification_email.token),
    ).school_partnership_notification_email.deliver_now.delivery_method.response.id

    notification_email.update!(notify_id:)
  end

  def send_notification_email_to_coordinator(notification_email, coordinator)
    notify_id = SchoolMailer.with(
      coordinator:,
      partnership: notification_email.partnership,
      sign_in_url: Rails.application.routes.url_helpers.new_user_session_url(
        host: Rails.application.config.domain,
        **UTMService.email(:partnership_notification, :partnership_notification),
      ),
      challenge_url: challenge_url(notification_email.token),
    ).coordinator_partnership_notification_email.deliver_now.delivery_method.response.id

    notification_email.update!(notify_id:)
  end

  def challenge_url(token, utm_source: :challenge_partnership)
    Rails.application.routes.url_helpers.challenge_partnership_url(
      token:,
      host: Rails.application.config.domain,
      **UTMService.email(utm_source, utm_source),
    )
  end

  def generate_token
    loop do
      value = SecureRandom.hex(16)
      break value unless PartnershipNotificationEmail.exists?(token: value)
    end
  end
end
