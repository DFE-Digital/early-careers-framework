# frozen_string_literal: true

class Schools::PartnershipsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @school = current_user.induction_coordinator_profile.schools.first
    @partnership = Partnership.find_by(school: @school, cohort: cohort)

    # if school.chosen_programme?(Cohort.current)
    #   redirect_to helpers.profile_dashboard_url(current_user)
    # else
    #   @induction_choice_form = InductionChoiceForm.new
    # end
  end

private

  def cohort
    @cohort ||= Cohort.find_by(start_year: params[:id])
  end
end
