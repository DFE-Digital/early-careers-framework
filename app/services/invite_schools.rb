# frozen_string_literal: true

class InviteSchools
  EMAIL_COOLDOWN_PERIOD = 24.hours

  def run(school_urns)
    logger.info "Emailing schools"

    school_urns.each do |urn|
      school = School.eligible.find_by(urn: urn)

      if school.nil?
        logger.info "School not found, urn: #{urn} ... skipping"
        next
      end

      nomination_email = NominationEmail.create_nomination_email(
        sent_at: Time.zone.now,
        sent_to: school.contact_email,
        school: school,
      )

      send_nomination_email(nomination_email)
    rescue StandardError
      logger.info "Error emailing school, urn: #{urn} ... skipping"
    end
  end

  def sent_email_recently?(school)
    latest_nomination_email = NominationEmail.where(school: school).order(sent_at: :desc).first
    latest_nomination_email&.sent_within_last?(EMAIL_COOLDOWN_PERIOD) || false
  end

private

  def send_nomination_email(nomination_email)
    SchoolMailer.nomination_email(
      recipient: nomination_email.sent_to,
      reference: nomination_email.token,
      school_name: nomination_email.school.name,
      nomination_url: nomination_email.nomination_url,
      expiry_date: email_expiry_date,
    ).deliver_now
  end

  def email_expiry_date
    NominationEmail::NOMINATION_EXPIRY_TIME.from_now.strftime("%d/%m/%Y")
  end

  def logger
    @logger ||= Rails.logger
  end
end
