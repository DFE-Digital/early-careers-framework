# frozen_string_literal: true

class Induction::SetSchoolCohortAppropriateBody < BaseService
  def call
    set_appropriate_body
    school_cohort.save!
  end

private

  attr_reader :school_cohort, :appropriate_body_id, :appropriate_body_appointed

  def initialize(school_cohort:, appropriate_body_id:, appropriate_body_appointed:)
    @school_cohort = school_cohort
    @appropriate_body_id = appropriate_body_id
    @appropriate_body_appointed = appropriate_body_appointed
  end

  def set_appropriate_body
    if !appropriate_body_appointed
      school_cohort.appropriate_body_unknown = true
      school_cohort.appropriate_body = nil
    else
      school_cohort.appropriate_body_unknown = false
      school_cohort.appropriate_body_id = appropriate_body_id
    end
  end
end
