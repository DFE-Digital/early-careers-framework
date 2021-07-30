# frozen_string_literal: true

module Admin
  module Schools
    class CohortsController < Admin::BaseController
      skip_after_action :verify_authorized
      before_action :set_school

      def index
        @school_cohorts = policy_scope(SchoolCohort)
          .joins(:school)
          .where(school: @school)

        # We do not display the 2020 cohort, because it is non-standard
        @cohorts = Cohort.where.not(start_year: 2020).order(start_year: :asc)
      end

    private

      def set_school
        @school = School.friendly.find params[:school_id]
      end
    end
  end
end
