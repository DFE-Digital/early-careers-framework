# frozen_string_literal: true

class InviteEcts
  def fip_preterm_reminder(season:)
    Rails.logger.info "Sending reminder to fip SITs"

    SchoolCohort.includes(school: :induction_coordinators)
      .where(induction_programme_choice: :full_induction_programme, opt_out_of_updates: false).each do |cohort|
        cohort.school.induction_coordinator_profiles.each do |sit|
          next if Email.associated_with(sit).tagged_with(:fip_preterm_reminder).any?

          ParticipantMailer.fip_preterm_reminder(induction_coordinator_profile: sit, season: season, school_name: cohort.school_name).deliver_later
        end
      end
  end

  def cip_preterm_reminder(season:)
    Rails.logger.info "Sending reminder to cip SITs"

    SchoolCohort.includes(school: :induction_coordinators)
      .where(induction_programme_choice: :core_induction_programme, opt_out_of_updates: false).each do |cohort|
        cohort.school.induction_coordinator_profiles.each do |sit|
          next if Email.associated_with(sit).tagged_with(:cip_preterm_reminder).any?

          ParticipantMailer.cip_preterm_reminder(induction_coordinator_profile: sit, season: season, school_name: cohort.school.name).deliver_later
        end
      end
  end

  def school_preterm_reminder(season:)
    Rails.logger.info "Sending reminder to schools"

    cohort = Cohort.current
    School.eligible.reject { |s| s.chosen_programme(cohort) }.each do |school|
      next if school.induction_coordinators.any? || Email.associated_with(school).tagged_with(:school_preterm_reminder)

      SchoolMailer.school_preterm_reminder(school: school, season: season).deliver_later
    end
  end
end
