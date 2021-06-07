# frozen_string_literal: true

class Schools::CohortsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :set_school_cohort

  def show
    if @school_cohort.design_our_own?
      render "programme_choice_design_our_own"
    elsif @school_cohort.no_early_career_teachers?
      render "programme_choice_no_early_career_teachers"
    end
  end

  def add_participants; end
end
