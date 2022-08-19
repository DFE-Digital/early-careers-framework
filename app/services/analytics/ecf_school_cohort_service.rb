# frozen_string_literal: true

module Analytics
  class ECFSchoolCohortService
    class << self
      def upsert_record(school_cohort)
        return unless %w[test development production].include? Rails.env

        record = Analytics::ECFSchoolCohort.find_or_initialize_by(school_cohort_id: school_cohort.id)
        record.school_id = school_cohort.school_id
        record.school_name = school_cohort.school.name
        record.school_urn = school_cohort.school.urn

        record.cohort_id = school_cohort.cohort_id
        record.cohort = school_cohort.cohort.start_year

        record.induction_programme_choice = school_cohort.induction_programme_choice
        record.default_induction_programme_training_choice = school_cohort&.default_induction_programme&.training_programme

        record.appropriate_body_id = school_cohort.appropriate_body_id
        record.appropriate_body_unknown = school_cohort.appropriate_body_unknown

        record.created_at = school_cohort.created_at
        record.updated_at = school_cohort.updated_at

        record.save!
      end
    end
  end
end
