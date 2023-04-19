# frozen_string_literal: true

class UpdateInductionTutorReminder
  attr_reader :school

  def initialize(school, repeat_email_cutoff: 1.week.ago)
    @school = school
    @repeat_email_cutoff = repeat_email_cutoff
  end

  def send!
    sit_name = school&.induction_tutor&.full_name

    return if sit_name.blank?
    return if received_email_recently?

    SchoolMailer.remind_to_update_school_induction_tutor_details(
      school:,
      sit_name:,
      nomination_link:,
    ).deliver_now
  end

private

  def received_email_recently?
    Email
      .associated_with(school)
      .tagged_with(:remind_to_update_induction_tutor)
      .where(created_at: @repeat_email_cutoff..)
      .exists?
  end

  def nomination_link
    Rails
      .application
      .routes
      .url_helpers
      .start_nomination_nominate_induction_coordinator_url(
        token: nomination_email.token,
        host: Rails.application.config.domain,
      )
  end

  def nomination_email
    @nomination_email ||= NominationEmail.create_nomination_email(
      sent_at: Time.zone.now,
      sent_to: school.primary_contact_email,
      school:,
      partnership_notification_email: nil,
    )
  end
end
