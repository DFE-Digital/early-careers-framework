# frozen_string_literal: true

module Schools
  class CohortsController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :set_school_cohort

    def show
      if @school_cohort.can_change_programme?
        redirect_to(schools_dashboard_path) and return
      end

      render "programme_choice"
    end

    def roles
      @hide_button = true if params[:info]
    end

    def change_programme
      new_path = if @school_cohort.no_early_career_teachers? || @school_cohort.design_our_own?
                   schools_choose_programme_path
                 else
                   support_path(
                     cohort_year: @school_cohort.cohort.start_year,
                     school_id: @school.id,
                     subject: :"change-cohort-induction-programme-choice",
                   )
                 end

      redirect_to new_path
    end
  end
end
