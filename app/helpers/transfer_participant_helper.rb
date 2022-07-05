# frozen_string_literal: true

module TransferParticipantHelper
  def transfer_participant_in_cohort(cohort, school)
    school_cohort = SchoolCohort.find_by(school:, cohort:)

    if school_cohort&.full_induction_programme?
      what_we_need_schools_transferring_participant_path(cohort_id: cohort)
    else
      contact_support_schools_transferring_participant_path
    end
  end

private

  def doing_fip?(school_cohort)
    school_cohort.induction_programmes.any?(&:full_induction_programme?)
  end
end
