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
          .joins(:cohort)
          .order("cohorts.start_year ASC")
      end

    private

      def set_school
        @school = School.friendly.find params[:school_id]
      end
    end
  end
end
