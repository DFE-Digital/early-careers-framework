# frozen_string_literal: true

class AddParticipantsReminder
  def initialize(cohort:)
    @cohort = cohort
  end

  attr_reader :cohort

  # This is sent to SITs who have confirmed they are expecting ects and told us that it's either FIP or FIP
  # but have not added any ECTs or Mentors to the service yet.

  def fip_register_participants_reminder
    Rails.logger.info "Sending reminder to fip SITs"

    SchoolCohort.includes(school: :induction_coordinators)
                .where(induction_programme_choice: :full_induction_programme, cohort:).each do |school_cohort|
      next if school_cohort.ecf_participant_profiles.any?

      school_cohort.school.induction_coordinator_profiles.each do |sit|
        next if Email.associated_with(sit).tagged_with(:fip_register_participants_reminder).any?

        ParticipantMailer.with(
          induction_coordinator_profile: sit,
          school_name: school_cohort.school.name,
        ).fip_register_participants_reminder.deliver_later
      end
    end
  end

  def cip_register_participants_reminder
    Rails.logger.info "Sending reminder to cip SITs"

    SchoolCohort.includes(school: :induction_coordinators)
                .where(induction_programme_choice: :core_induction_programme, cohort:).each do |school_cohort|
      next if school_cohort.ecf_participant_profiles.any?

      school_cohort.school.induction_coordinator_profiles.each do |sit|
        next if Email.associated_with(sit).tagged_with(:cip_register_participants_reminder).any?

        ParticipantMailer.with(
          induction_coordinator_profile: sit,
          school_name: school_cohort.school.name,
        ).cip_register_participants_reminder.deliver_later
      end
    end
  end
end
