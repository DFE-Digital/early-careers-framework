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
end
