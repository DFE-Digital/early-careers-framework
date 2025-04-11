# frozen_string_literal: true

class Analytics::UpsertECFSchoolCohortJob < ApplicationJob
  def perform(school_cohort_id:)
    school_cohort = SchoolCohort.find_by(id: school_cohort_id)
    Analytics::ECFSchoolCohortService.upsert_record(school_cohort) if school_cohort
  end
end
