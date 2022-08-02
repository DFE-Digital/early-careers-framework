# frozen_string_literal: true

class Induction::SetSchoolCohortAppropriateBody < BaseService
  def call
    ActiveRecord::Base.transaction do
      set_school_cohort_appropriate_body
      set_induction_records_appropriate_body if update_induction_records
    end
  end

private

  attr_reader :school_cohort, :appropriate_body_id, :appropriate_body_appointed, :update_induction_records

  def initialize(school_cohort:, appropriate_body_id:, appropriate_body_appointed:, update_induction_records: false)
    @school_cohort = school_cohort
    @appropriate_body_id = appropriate_body_id
    @appropriate_body_appointed = appropriate_body_appointed
    @update_induction_records = update_induction_records
  end

  def set_school_cohort_appropriate_body
    if appropriate_body_appointed == false
      school_cohort.appropriate_body_unknown = true
      school_cohort.appropriate_body = nil
    else
      school_cohort.appropriate_body_unknown = false
      school_cohort.appropriate_body_id = appropriate_body_id
    end
    school_cohort.save!
  end

  def set_induction_records_appropriate_body
    school_cohort.induction_records.update_all(appropriate_body_id:)
  end
end
