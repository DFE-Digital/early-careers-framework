# frozen_string_literal: true

class PartnershipActivationJob < ApplicationJob
  discard_on ActiveJob::DeserializationError

  def perform(partnership:, report_id:)
    return if partnership.challenged? || partnership.report_id != report_id
    return unless partnership.pending

    ActiveRecord::Base.transaction do
      partnership.update!(pending: false)
      school_cohort = SchoolCohort.find_by!(school_id: partnership.school_id, cohort_id: partnership.cohort_id)
      school_cohort.update!(induction_programme_choice: "full_induction_programme", core_induction_programme: nil)
    end
  end
end
