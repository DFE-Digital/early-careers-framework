# frozen_string_literal: true

class InviteEcts
  # This is sent to SITs who were set up in a previous cohort. We request
  # that they choose a programme for the next cohort and add their ECTs, if neccessary.
  def preterm_reminder(conditions: {})
    School.eligible.joins(:induction_coordinators).includes(:school_cohorts).where(conditions).each do |school|
      # Filter out children's centres from these communications
      next if GiasTypes::NO_INVITATIONS_TYPE_CODES.include?(school.school_type_code)

      school.induction_coordinator_profiles.each do |sit|
        # Already received this email
        next if Email.associated_with(sit).tagged_with(:preterm_reminder_unconfirmed_for_2022).any?

        # Already chosen a programme this cohort
        next if school.chosen_programme?(Cohort.current)

        ParticipantMailer.with(induction_coordinator_profile: sit).preterm_reminder_unconfirmed_for_2022.deliver_later
      end
    end
  end

  # A pre-term reminder to request that a school nominate an induction coordinator.
  def school_preterm_reminder(season:)
    cohort = Cohort.current
    School.includes(:induction_coordinators).eligible.reject { |s| s.chosen_programme?(cohort) }.each do |school|
      next if school.induction_coordinators.any? || Email.associated_with(school).tagged_with(:school_preterm_reminder).any?

      SchoolMailer.with(school:, season:).school_preterm_reminder.deliver_later
    end
  end
end
