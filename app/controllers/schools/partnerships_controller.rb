# frozen_string_literal: true

class Schools::PartnershipsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @school = current_user.induction_coordinator_profile.schools.first
    @partnership = @school.partnerships.active.find_by(cohort: cohort)

    if @partnership&.in_challenge_window?
      @report_mistake_link = challenge_partnership_path(partnership: @partnership)
      @mistake_link_expiry = @partnership.challenge_deadline.strftime("%d/%m/%Y")
    end
  end

private

  def cohort
    @cohort ||= Cohort.find_by(start_year: params[:cohort_id])
  end
end
