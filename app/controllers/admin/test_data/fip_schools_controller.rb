# frozen_string_literal: true

module Admin::TestData
  class FipSchoolsController < Admin::TestData::BaseController
    def index
      @pagy, @schools = pagy(find_schools, page: params[:page], limit: 10)
    end

  private

    def find_schools
      policy_scope(School)
        .joins(:induction_coordinator_profiles_schools, school_cohorts: :cohort)
        .includes(partnerships: %i[lead_provider delivery_partner])
        .merge(SchoolCohort.full_induction_programme)
        .where(school_cohorts: { cohort: Cohort.current })
        .distinct
        .order(:urn)
    end
  end
end
