# frozen_string_literal: true

module Schools
  class CohortsController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :set_school_cohort
    before_action :set_partnership, only: %i[change_programme]

    def show
      if @school_cohort.can_change_programme?
        redirect_to(schools_dashboard_path) and return
      end

      render "programme_choice"
    end

    def roles
      @hide_button = true if params[:info]
    end

    def change_programme; end

  private

    def set_partnership
      return unless @school_cohort.school_chose_fip?

      @partnership = @school.partnerships.unchallenged.find_by(cohort: @school_cohort.cohort)
    end
  end
end
