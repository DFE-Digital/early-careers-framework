# frozen_string_literal: true

class InviteEcts
  def fip_preterm_reminder(season:)
    logger.info "Sending reminder to fip SITs"

    SchoolCohort.includes(school: :induction_coordinators)
      .where(induction_programme_choice: :full_induction_programme, opt_out_of_updates: false).each do |cohort|
      cohort.school.induction_coordinator_profiles.each do |sit|
        next if Email.associated_with(sit).tagged_with(:fip_preterm_reminder).any?

        PaticipantMailer.fip_preterm_reminder(induction_coordinator: sit, season: season).deliver_later
      end
    end
  end

  def cip_preterm_reminder(season:)
    logger.info "Sending reminder to cip SITs"

    SchoolCohort.includes(school: :induction_coordinators)
      .where(induction_programme_choice: :core_induction_programme, opt_out_of_updates: false).each do |cohort|
      cohort.school.induction_coordinator_profiles.each do |sit|
        next if Email.associated_with(sit).tagged_with(:cip_preterm_reminder).any?

        PaticipantMailer.cip_preterm_reminder(induction_coordinator: sit, season: season).deliver_later
      end
    end
  end

  def school_preterm_reminder(season:)
    logger.info "Sending reminder to schools"

    SchoolCohort.includes(school: :induction_coordinators)
      .where(induction_programme_choice: nil, opt_out_of_updates: false).each do |cohort|
      next if cohort.induction_coordinators.any? || Email.associated_with(cohort.school).tagged_with(:school_preterm_reminder)

      SchoolMailer.school_preterm_reminder(school: cohort.school, season: season).deliver_later
    end
  end
end
