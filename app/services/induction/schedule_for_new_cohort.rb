# frozen_string_literal: true

class Induction::ScheduleForNewCohort < BaseService
  EXTENDED_SCHEDULE_IDENTIFIER = "ecf-extended-september"

  def call
    return induction_record.schedule if induction_record && induction_record.cohort == cohort

    Finance::Schedule::ECF.find_by(cohort:, schedule_identifier:) ||
      Finance::Schedule::ECF.default_for(cohort:)
  end

private

  attr_reader :cohort, :induction_record, :cohort_changed_after_payments_frozen

  def initialize(cohort:, induction_record:, cohort_changed_after_payments_frozen: false)
    @cohort = cohort
    @induction_record = induction_record
    @cohort_changed_after_payments_frozen = cohort_changed_after_payments_frozen
  end

  def schedule_identifier
    cohort_changed_after_payments_frozen ? EXTENDED_SCHEDULE_IDENTIFIER : induction_record&.schedule_identifier
  end
end
