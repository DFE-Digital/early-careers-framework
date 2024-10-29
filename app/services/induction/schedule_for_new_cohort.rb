# frozen_string_literal: true

class Induction::ScheduleForNewCohort < BaseService
  EXTENDED_SCHEDULE_IDENTIFIER = "ecf-extended-september"

  def call
    return induction_record.schedule if induction_record && induction_record.cohort == cohort

    Finance::Schedule::ECF.find_by(cohort:, schedule_identifier:) ||
      Finance::Schedule::ECF.default_for(cohort:)
  end

private

  attr_reader :cohort, :induction_record, :extended_schedule

  def initialize(cohort:, induction_record:, extended_schedule: false)
    @cohort = cohort
    @induction_record = induction_record
    @extended_schedule = extended_schedule
  end

  def schedule_identifier
    extended_schedule ? EXTENDED_SCHEDULE_IDENTIFIER : induction_record&.schedule_identifier
  end
end
