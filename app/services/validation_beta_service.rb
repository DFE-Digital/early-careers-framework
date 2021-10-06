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
          recipient: sit.user.email,
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
        next if Email.associated_with(sit).tagged_with(:reminder_request_to_add_ects_and_mentors).any?

        SchoolMailer.remind_fip_induction_coordinators_to_add_ects_and_mentors_email(
          induction_coordinator: sit,
          school_name: school.name,
          campaign: :remind_fip_sit_to_complete_steps,
        ).deliver_later
      end
    end
  end

  def set_up_missing_chasers
    participants_yet_to_validate.find_each do |profile|
      next if chaser_scheduled?(profile)

      ParticipantDetailsReminderJob.schedule(profile)
    end
  end

  def chosen_programme_and_not_in_beta(school)
    !FeatureFlag.active?(:participant_validation, for: school) && school.chosen_programme?(Cohort.current)
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

  def chaser_scheduled?(profile)
    Delayed::Job.where("handler ILIKE ?", "%ParticipantDetailsReminderJob%#{profile.id}%").exists?
  end
end
