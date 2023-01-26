# frozen_string_literal: true

module Admin::TestData
  class YetToChooseSchoolsController < Admin::TestData::BaseController
    def index
      @pagy, @schools = pagy(find_schools, page: params[:page], items: 10)
    end

  private

    def find_schools
      policy_scope(School)
        .joins(:induction_coordinator_profiles_schools)
        .left_joins(school_cohorts: :cohort)
        .where.not(id: SchoolCohort.where(cohort: Cohort.current).select(:school_id))
        .order(:urn)
    end
  end
end
