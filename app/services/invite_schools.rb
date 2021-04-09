# frozen_string_literal: true

class InviteSchools
  EMAIL_COOLDOWN_PERIOD = 24.hours

  def run(school_urns)
    logger = Rails.logger
    logger.info "Emailing schools"

    school_urns.each do |urn|
      school = School.eligible.find_by(urn: urn)

      if school.nil?
        logger.info "School not found, urn: #{urn} ... skipping"
        next
      end

      token = reference
      recipient = recipient_email(school)

      school.nomination_emails.create!(
        token: token,
        sent_to: recipient,
        sent_at: Time.zone.now,
      )
      send_nomination_email(recipient, token, school.name)
    rescue StandardError
      logger.info "Error emailing school, urn: #{urn} ... skipping"
    end
  end

  def sent_email_recently?(school)
    latest_nomination_email = NominationEmail.where(school: school).order(sent_at: :desc).first
    latest_nomination_email&.sent_within_last?(EMAIL_COOLDOWN_PERIOD) || false
  end

private

  def send_nomination_email(recipient, token, school_name)
    SchoolMailer.nomination_email(
      recipient: recipient,
      reference: token,
      school_name: school_name,
      nomination_url: nomination_url(token),
    ).deliver_now
  end

  def recipient_email(school)
    return school.secondary_contact_email unless school.primary_contact_email

    school.primary_contact_email
  end

  def reference
    loop do
      value = SecureRandom.hex(16)
      break value unless NominationEmail.exists?(token: value)
    end
  end

  def nomination_url(token)
    token
    # Rails.application.routes.url_helpers.nominations_url( # TODO
    #   token: token,
    #   host: Rails.application.config.domain,
    # )
  end
end
