# frozen_string_literal: true

class Schools::CohortsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :set_school_cohort

  def show; end

  def add_participants
    redirect_to schools_cohort_participants_path(@cohort.start_year) if FeatureFlag.active?(:induction_tutor_manage_participants)
  end
end
