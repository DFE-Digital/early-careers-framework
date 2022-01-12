# frozen_string_literal: true

class InviteSchools
  EMAIL_LIMITS = [
    { max: 5, within: 24.hours },
    { max: 1, within: 5.minutes },
  ].freeze

  def run(school_urns)
    logger.info "Emailing schools"

    school_urns.each do |urn|
      school = find_school(urn)
      next if school.nil?

      access_token = SchoolAccessToken.create!(
        school: school,
        permitted_actions: %i[nominate_tutor],
      )

      begin
        send_nomination_email(to: school.contact_email, access_token: access_token)
      rescue Notifications::Client::RateLimitError
        sleep(1)
        retry
      end
    rescue StandardError
      logger.info "Error emailing school, urn: #{urn} ... skipping"
    end
  end

  def reached_limit(school)
    EMAIL_LIMITS.find do |within:, max:|
      Email
        .associated_with(school)
        .tagged_with(:request_to_nominate_sit)
        .where(created_at: within.ago..Float::INFINITY)
        .count >= max
    end
  end

  def send_ministerial_letters
    School.eligible.each do |school|
      recipient = school.contact_email
      delay(queue: "mailers").send_ministerial_letter(recipient) if recipient.present?
    end
  end

  def inform_diy_schools_of_wordpress
    User.where(
      id: diy_school_cohorts_without_pending_partnerships
            .joins(school: :induction_coordinators)
            .select(:user_id),
    ).find_each do |user|
      SchoolMailer.diy_wordpress_notification(
        user: user,
      ).deliver_later
    end
  end

private

  def private_beta_start_url
    Rails.application.routes.url_helpers.root_url(
      host: Rails.application.config.domain,
      **UTMService.email(:june_private_beta, :private_beta),
    )
  end

  def year2020_start_url(school, utm_source:)
    Rails.application.routes.url_helpers.start_schools_year_2020_url(
      host: Rails.application.config.domain,
      **UTMService.email(utm_source, utm_source),
      school_id: school.friendly_id,
    )
  end

  def sign_in_url_with_campaign(campaign)
    Rails.application.routes.url_helpers.new_user_session_url(
      host: Rails.application.config.domain,
      **UTMService.email(campaign, campaign),
    )
  end

  def choose_route_chaser_sign_in_url
    sign_in_url_with_campaign(:choose_route)
  end

  def choose_provider_chaser_sign_in_url
    sign_in_url_with_campaign(:choose_provider)
  end

  def choose_materials_chaser_sign_in_url
    sign_in_url_with_campaign(:choose_materials)
  end

  def add_participants_chaser_sign_in_url
    sign_in_url_with_campaign(:add_participants)
  end

  def find_school(urn)
    school = School.find_by(urn: urn)
    logger.info "School not found, urn: #{urn} ... skipping" unless school&.can_access_service?
    school
  end

  def create_and_send_nomination_email(email, school)
    access_token = SchoolAccessToken.create!(
      school: school,
      permitted_actions: %i[nominate_tutor],
    )
    send_nomination_email(to: email, access_token: access_token)
  end

  def send_nomination_email(to:, access_token:)
    SchoolMailer.nomination_email(
      recipient: to,
      school: access_token.school,
      access_token: access_token,
    ).deliver_later
  end

  def send_ministerial_letter(recipient)
    SchoolMailer.ministerial_letter_email(recipient: recipient).deliver_now
  rescue Notifications::Client::RateLimitError
    sleep(1)
    SchoolMailer.ministerial_letter_email(recipient: recipient).deliver_now
  end

  def email_expiry_date
    NominationEmail::NOMINATION_EXPIRY_TIME.from_now.strftime("%d/%m/%Y")
  end

  def logger
    @logger ||= Rails.logger
  end

  def diy_school_cohorts_with_pending_partnerships
    SchoolCohort.where(cohort_id: Cohort.current.id, induction_programme_choice: "design_our_own").joins(school: :partnerships).where(school: { partnerships: { challenge_reason: nil } })
  end

  def diy_school_cohorts_without_pending_partnerships
    SchoolCohort
      .where(cohort_id: Cohort.current.id, induction_programme_choice: "design_our_own")
      .where.not(id: diy_school_cohorts_with_pending_partnerships)
  end
end
