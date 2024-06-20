# frozen_string_literal: true

class Induction::ScheduleForNewCohort < BaseService
  def call
    if induction_record && induction_record.cohort == cohort
      induction_record.schedule
    else
      Finance::Schedule::ECF.find_by(cohort:,
                                     schedule_identifier: induction_record&.schedule_identifier) ||
        Finance::Schedule::ECF.default_for(cohort:)
    end
  end

private

  attr_reader :cohort, :induction_record

  def initialize(cohort:, induction_record:)
    @cohort = cohort
    @induction_record = induction_record
  end
end
