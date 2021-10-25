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

    def add_participants
      if FeatureFlag.active?(:induction_tutor_manage_participants, for: @school)
        redirect_to schools_participants_path(@cohort)
      end
    end

    def roles
      @hide_button = true if params[:info]
    end
  end
end
