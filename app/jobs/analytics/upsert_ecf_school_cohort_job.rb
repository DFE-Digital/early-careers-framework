# frozen_string_literal: true

class Analytics::UpsertECFSchoolCohortJob < ApplicationJob
  def perform(school_cohort:)
    # Analytics::ECFSchoolCohortService.upsert_record(school_cohort)
  end
end
