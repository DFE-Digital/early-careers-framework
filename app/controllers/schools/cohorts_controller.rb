# frozen_string_literal: true

module Schools
  class CohortsController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :set_school_cohort

    def show
      if @school_cohort.design_our_own?
        render "programme_choice_design_our_own"
      elsif @school_cohort.no_early_career_teachers?
        render "programme_choice_no_early_career_teachers"
      else
        render "programme_choice"
      end
    end

    def add_participants
      if FeatureFlag.active?(:induction_tutor_manage_participants, for: @school)
        redirect_to schools_participants_path(@cohort)
      end
    end

    def roles
      render "shared/roles"
    end
  end
end
