# frozen_string_literal: true

class ValidationBetaService
  def remind_sits_to_add_participants
    empty_school_cohorts = SchoolCohort
                             .where(induction_programme_choice: %i[full_induction_programme core_induction_programme not_yet_known])
                             .where(opt_out_of_updates: false)
                             .where.not(id: ParticipantProfile::ECF.select(:school_cohort_id))
    School.where(id: empty_school_cohorts.select(:school_id)).includes(:induction_coordinators).find_each do |school|
      school.induction_coordinator_profiles.each do |sit|
        next if sit.reminder_email_sent_at.present?

        email = SchoolMailer.remind_induction_coordinator_to_setup_cohort_email(
          induction_coordinator_profile: sit,
          school_name: school.name,
          campaign: :sit_to_complete_steps,
        )

        ActiveRecord::Base.transaction do
          sit.update_column(:reminder_email_sent_at, Time.zone.now)
          email.deliver_later
        end
      end
    end
  end

  def remind_fip_induction_coordinators_to_add_ect_and_mentors
    empty_school_cohorts = SchoolCohort
                             .where(induction_programme_choice: %i[full_induction_programme])
                             .where(opt_out_of_updates: false)
                             .where.not(id: ParticipantProfile::ECF.select(:school_cohort_id))

    School.where(id: empty_school_cohorts.select(:school_id)).includes(:induction_coordinators).find_each do |school|
      school.induction_coordinator_profiles.each do |sit|
        next if Email.associated_with(sit).tagged_with(:fifth_request_to_add_ects_and_mentors).any?

        SchoolMailer.remind_fip_induction_coordinators_to_add_ects_and_mentors_email(
          induction_coordinator: sit,
          school_name: school.name,
          campaign: :remind_fip_sit_to_complete_steps,
        ).deliver_later
      end
    end
  end

  def send_ects_to_add_validation_information(profile, school)
    campaign = :ect_validation_info_2709

    participant_validation_start_url = Rails.application.routes.url_helpers.participants_start_registrations_url(
      host: Rails.application.config.domain,
      **UTMService.email(campaign, campaign),
    )

    email = ParticipantValidationMailer.ects_to_add_validation_information_email(
      recipient: profile.user.email,
      school_name: school.name,
      start_url: participant_validation_start_url,
    )

    ActiveRecord::Base.transaction do
      email.deliver_later
      profile.update_column(:request_for_details_sent_at, Time.zone.now)
    end
  end

  def send_mentors_to_add_validation_information(profile, school)
    campaign = :mentor_validation_info_2709

    participant_validation_start_url = Rails.application.routes.url_helpers.participants_start_registrations_url(
      host: Rails.application.config.domain,
      **UTMService.email(campaign, campaign),
    )

    email = ParticipantValidationMailer.mentors_to_add_validation_information_email(
      recipient: profile.user.email,
      school_name: school.name,
      start_url: participant_validation_start_url,
    )

    ActiveRecord::Base.transaction do
      email.deliver_later
      profile.update_column(:request_for_details_sent_at, Time.zone.now)
    end
  end

  def send_induction_coordinators_who_are_mentors_to_add_validation_information(profile, school)
    campaign = :sit_mentor_validation_info_2709

    participant_validation_start_url = Rails.application.routes.url_helpers.participants_start_registrations_url(
      host: Rails.application.config.domain,
      **UTMService.email(campaign, campaign),
    )

    email = ParticipantValidationMailer.induction_coordinators_who_are_mentors_to_add_validation_information_email(
      recipient: profile.user.email,
      school_name: school.name,
      start_url: participant_validation_start_url,
    )

    ActiveRecord::Base.transaction do
      email.deliver_later
      profile.update_column(:request_for_details_sent_at, Time.zone.now)
    end
  end

  def participants_yet_to_validate
    ParticipantProfile::ECF
      .ecf
      .active_record
      .includes(:ecf_participant_eligibility, :ecf_participant_validation_data, :school_cohort)
      .where(
        school_cohort: {
          cohort: Cohort.current,
          induction_programme_choice: %w[core_induction_programme full_induction_programme],
        },
        ecf_participant_eligibility: {
          participant_profile_id: nil,
        },
        ecf_participant_validation_data: {
          participant_profile_id: nil,
        },
      )
  end

  def sit_with_unvalidated_participants_reminders
    InductionCoordinatorProfile
      .joins(schools: :active_ecf_participant_profiles)
      .includes(schools: { active_ecf_participant_profiles: %i[ecf_participant_eligibility ecf_participant_validation_data] })
      .where(
        school_cohorts: {
          cohort_id: Cohort.current.id,
          induction_programme_choice: %w[core_induction_programme full_induction_programme],
        },
        ecf_participant_eligibility: {
          participant_profile_id: nil,
        },
        ecf_participant_validation_data: {
          participant_profile_id: nil,
        },
      ).distinct.find_each do |sit|
      campaign = :unvalidated_participants_reminder

      sign_in_url = Rails.application.routes.url_helpers.new_user_session_url(
        host: Rails.application.config.domain,
        **UTMService.email(campaign, campaign),
      )

      participant_validation_start_url = Rails.application.routes.url_helpers.participants_start_registrations_url(
        host: Rails.application.config.domain,
        **UTMService.email(campaign, campaign),
      )

      ParticipantValidationMailer.induction_coordinators_we_asked_ects_and_mentors_for_information_email(
        recipient: sit.user.email,
        start_url: participant_validation_start_url,
        sign_in: sign_in_url,
        induction_coordinator_profile: sit,
      ).deliver_later
    end
  end

  def sit_fip_with_unvalidated_participants_deadline_reminders
    campaign = :unvalidated_participants_deadline_reminder

    sign_in_url = Rails.application.routes.url_helpers.new_user_session_url(
      host: Rails.application.config.domain,
      **UTMService.email(campaign, campaign),
    )

    participant_start_url = Rails.application.routes.url_helpers.participants_start_registrations_url(
      host: Rails.application.config.domain,
      **UTMService.email(campaign, campaign),
    )

    InductionCoordinatorProfile
      .joins(schools: %i[active_ecf_participant_profiles partnerships])
      .includes(schools: { active_ecf_participant_profiles: %i[ecf_participant_eligibility ecf_participant_validation_data] })
      .where(
        school_cohorts: {
          cohort_id: Cohort.current.id,
          induction_programme_choice: "full_induction_programme",
        },
        ecf_participant_eligibility: {
          participant_profile_id: nil,
        },
        ecf_participant_validation_data: {
          participant_profile_id: nil,
        },
      )
      .merge(Partnership.active)
      .distinct
      .find_each do |sit|
        sit.schools
          .joins(:school_cohorts, :partnerships)
          .where(school_cohorts: { cohort_id: Cohort.current.id })
          .merge(Partnership.active)
          .find_each do |school|
          participants = school
            .school_cohorts
            .find_by(cohort_id: Cohort.current.id)
            .active_ecf_participant_profiles
            .contacted_for_info

          next unless participants.any?

          participant_name_list = participant_name_markdown_list(participants)

          SchoolMailer.sit_fip_participant_validation_deadline_reminder_email(
            induction_coordinator_profile: sit,
            participant_name_list:,
            participant_start_url:,
            sign_in_url:,
          ).deliver_later

          participants.each do |participant_profile|
            ParticipantValidationMailer.fip_participant_validation_deadline_reminder_email(
              participant_profile:,
              participant_start_url:,
            ).deliver_later
          end
        end
      end
  end

  def send_sit_new_ambition_ects_and_mentors_added(path_to_csv:)
    sign_in_url = Rails.application.routes.url_helpers.new_user_session_url(
      host: Rails.application.config.domain,
    )

    sit_ids = []

    CSV.foreach(path_to_csv, headers: true) do |row|
      participant_email = row["email"]
      next if participant_email.blank?

      user = Identity.find_user_by(email: participant_email)
      next if user.nil?

      sit = user&.school&.induction_coordinator_profiles&.first

      if sit.present?
        next if sit_ids.include?(sit.id) || Email.associated_with(sit).tagged_with(:sit_new_ambition_participants_added).any?

        SchoolMailer.sit_new_ambition_ects_and_mentors_added_email(
          induction_coordinator_profile: sit,
          school_name: user.school.name,
          sign_in_url:,
        ).deliver_later
        sit_ids << sit.id
      else
        Rails.logger.warn("Not sending email to SIT of #{participant_email}")
      end
    end
    Rails.logger.info("Sent emails to #{sit_ids.count} induction coordinators")
  end

  def send_ineligible_previous_induction_batch(batch_size: 200)
    sent = 0
    ECFParticipantEligibility.ineligible_status.previous_induction_reason.find_each do |eligibility|
      next if Email.tagged_with(:ineligible_participant).associated_with(eligibility.participant_profile).any?
      next if eligibility.participant_profile.withdrawn_record?
      next unless eligibility.participant_profile.school_cohort.full_induction_programme?

      tutor_email = eligibility.participant_profile.school.contact_email
      IneligibleParticipantMailer.ect_previous_induction_email(
        induction_tutor_email: tutor_email,
        participant_profile: eligibility.participant_profile,
      ).deliver_later
      sent += 1
      break if sent >= batch_size
    end
  end

  def inform_sits_of_bounced_emails
    sign_in_url = Rails.application.routes.url_helpers.new_user_session_url(
      host: Rails.application.config.domain,
      **UTMService.email(:sit_participant_email_bounced),
    )

    unvalidated_participant_profiles_with_failed_email_in_the_last_month = ParticipantProfile::ECF.joins(
      :user,
      :school_cohort,
    ).where(
      school_cohort:
        { cohort_id: Cohort.current.id },
      user: {
        id: Email::Association.where(name: "recipient")
                              .joins(:email)
                              .where(email: {
                                status: %w[permanent-failure temporary-failure technical-failure],
                              })
                              .where("email.created_at > ?", 1.month.ago)
                              .pluck(:object_id),
      },
    ).contacted_for_info.active_record

    unvalidated_participant_profiles_with_failed_email_in_the_last_month.each do |participant_profile|
      next if Email.associated_with(participant_profile).tagged_with(:sit_participant_email_bounced).any?

      tutor_email = participant_profile.school.contact_email
      ParticipantValidationMailer.induction_coordinator_participant_email_bounced_email(
        recipient: tutor_email,
        sign_in_url:,
        participant_profile:,
      ).deliver_later
    end
  end

  def participant_name_markdown_list(participants)
    participants.map { |p| "- #{p.user.full_name}" }.join("\n")
  end
end
