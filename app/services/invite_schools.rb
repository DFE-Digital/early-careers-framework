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

      nomination_email = school.nomination_emails.create!(
        token: generate_token,
        sent_to: recipient_email(school),
        sent_at: Time.zone.now,
      )
      send_nomination_email(
        nomination_email.sent_to,
        nomination_email.token,
        school.name,
        email_expiry_date,
      )
    rescue StandardError
      logger.info "Error emailing school, urn: #{urn} ... skipping"
    end
  end

  def sent_email_recently?(school)
    latest_nomination_email = NominationEmail.where(school: school).order(sent_at: :desc).first
    latest_nomination_email&.sent_within_last?(EMAIL_COOLDOWN_PERIOD) || false
  end

private

  def send_nomination_email(recipient, token, school_name, email_expiry_date)
    SchoolMailer.nomination_email(
      recipient: recipient,
      reference: token,
      school_name: school_name,
      nomination_url: nomination_url(token),
      expiry_date: email_expiry_date,
    ).deliver_now
  end

  def recipient_email(school)
    school.primary_contact_email || school.secondary_contact_email
  end

  def generate_token
    loop do
      value = SecureRandom.hex(16)
      break value unless NominationEmail.exists?(token: value)
    end
  end

  def nomination_url(token)
    Rails.application.routes.url_helpers.start_nominate_induction_coordinator_url(
      token: token,
      host: Rails.application.config.domain,
    )
  end

  def email_expiry_date
    NominationEmail::NOMINATION_EXPIRY_TIME.from_now.strftime("%d/%m/%Y")
  end

  def logger
    @logger ||= Rails.logger
  end
end
