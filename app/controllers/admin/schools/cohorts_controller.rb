# frozen_string_literal: true

module Admin
  module Schools
    class CohortsController < Admin::BaseController
      skip_after_action :verify_authorized

      def index
        @school = School.eager_load(:active_partnerships).friendly.find(params[:school_id])

        @partnerships_by_cohort = @school.active_partnerships.group_by(&:cohort_id)

        @school_cohorts = policy_scope(SchoolCohort)
          .joins(:school)
          .where(school: @school)

        # We do not display the 2020 cohort, because it is non-standard
        @cohorts = Cohort
          .where
          .not(start_year: 2020)
          .where(start_year: ..Cohort.active_registration_cohort.start_year)
          .order(start_year: :desc)
      end
    end
  end
end
