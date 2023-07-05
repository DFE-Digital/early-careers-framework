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

        @cohorts = Cohort.current_national_rollout_year.order(start_year: :asc)
      end

    private

      def set_school
        @school = School.eager_load(:active_partnerships).friendly.find(params[:school_id])
        @partnerships_by_cohort = @school.active_partnerships.group_by(&:cohort_id)
      end
    end
  end
end
