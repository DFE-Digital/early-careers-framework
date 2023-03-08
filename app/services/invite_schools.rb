# frozen_string_literal: true

class InviteSchools
  include Sidekiq::Worker

  EMAIL_LIMITS = [
    { max: 5, within: 24.hours },
    { max: 1, within: 5.minutes },
  ].freeze

  def perform(school_urns)
    logger.info "Emailing schools"

    school_urns.each do |urn|
      school = find_school(urn)
      next if school.nil?

      nomination_email = NominationEmail.create_nomination_email(
        sent_at: Time.zone.now,
        sent_to: school.contact_email,
        school:,
      )

      if school.registered?
        send_nomination_email(nomination_email)
      else
        send_replace_tutor_email(nomination_email)
      end
    rescue Notifications::Client::RateLimitError
      sleep(1)
      send_nomination_email(nomination_email)
    rescue StandardError => e
      logger.info "Error emailing school, urn: #{urn} ... skipping. Error: #{e}"
    end
  end

  def reached_limit(school)
    EMAIL_LIMITS.find do |kwargs|
      NominationEmail.where(school:, sent_at: kwargs[:within].ago..Float::INFINITY).count >= kwargs[:max]
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
        user:,
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
    school = School.find_by(urn:)
    logger.info "School not found, urn: #{urn} ... skipping" unless school&.can_access_service?
    school
  end

  def create_and_send_nomination_email(email, school)
    nomination_email = NominationEmail.create_nomination_email(
      sent_at: Time.zone.now,
      sent_to: email,
      school:,
    )
    send_nomination_email(nomination_email)
  rescue Notifications::Client::RateLimitError
    sleep(1)
    send_nomination_email(nomination_email)
  end

  def send_nomination_email(nomination_email)
    notify_id = SchoolMailer.nomination_email(
      recipient: nomination_email.sent_to,
      school: nomination_email.school,
      nomination_url: nomination_email.nomination_url,
      expiry_date: email_expiry_date,
    ).deliver_now.delivery_method.response.id

    nomination_email.update!(notify_id:)
  end

  def send_replace_tutor_email(nomination_email)
    notify_id = SchoolMailer.school_requested_signin_link_from_gias_email(
      school: nomination_email.school,
      nomination_url: nomination_email.nomination_url,
    ).deliver_now.delivery_method.response.id

    nomination_email.update!(notify_id:)
  end

  def send_ministerial_letter(recipient)
    SchoolMailer.ministerial_letter_email(recipient:).deliver_now
  rescue Notifications::Client::RateLimitError
    sleep(1)
    SchoolMailer.ministerial_letter_email(recipient:).deliver_now
  end

  def email_expiry_date
    NominationEmail::NOMINATION_EXPIRY_TIME.from_now.to_date.to_s(:govuk)
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
