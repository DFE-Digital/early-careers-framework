# frozen_string_literal: true

class InviteSchools
  EMAIL_COOLDOWN_PERIOD = 24.hours

  def run(school_urns)
    logger.info "Emailing schools"

    school_urns.each do |urn|
      rate_limit
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

  def send_chasers
    logger.info "Sending chaser emails"
    logger.info "Nomination email count before: #{NominationEmail.count}"
    School.eligible.without_induction_coordinator.each do |school|
      additional_emails = school.additional_school_emails.pluck(:email_address)
      emails = [school.primary_contact_email, school.secondary_contact_email, *additional_emails]
                 .reject(&:blank?)
                 .map(&:downcase)
                 .uniq

      emails.each do |email|
        rate_limit
        nomination_email = NominationEmail.create_nomination_email(
          sent_at: Time.zone.now,
          sent_to: email,
          school: school,
        )
        send_nomination_email(nomination_email)
      rescue StandardError
        logger.info "Error emailing school, urn: #{school.urn}, email: #{email} ... skipping"
      end
    end

    logger.info "Chaser emails sent"
    logger.info "Nomination email count after: #{NominationEmail.count}"
  end

private

  def send_nomination_email(nomination_email)
    notify_id = SchoolMailer.nomination_email(
      recipient: nomination_email.sent_to,
      school_name: nomination_email.school.name,
      nomination_url: nomination_email.nomination_url,
      expiry_date: email_expiry_date,
    ).deliver_now.delivery_method.response.id

    nomination_email.update!(notify_id: notify_id)
  end

  def email_expiry_date
    NominationEmail::NOMINATION_EXPIRY_TIME.from_now.strftime("%d/%m/%Y")
  end

  # Notify gives us a 3000/min rate limit. Limit this to 1800/min to allow for other calls and leeway
  def rate_limit
    @second_start ||= Time.zone.now
    @calls_in_second ||= 0

    if @second_start < 1.second.ago
      @second_start = Time.zone.now
      @calls_in_second = 1
      return
    end

    @calls_in_second += 1
    sleep((@second_start + 1.second) - Time.zone.now) if @calls_in_second >= 30
  end

  def logger
    @logger ||= Rails.logger
  end
end
