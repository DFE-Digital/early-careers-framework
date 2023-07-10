# frozen_string_literal: true

class Schools::PartnershipsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @school = active_school
    @partnership = @school.partnerships.active.find_by(cohort:)

    if @partnership&.in_challenge_window?
      @report_mistake_link = challenge_partnership_path(partnership: @partnership)
      @mistake_link_expiry = @partnership.challenge_deadline&.to_date&.to_fs(:govuk)
    end
  end

private

  def cohort
    @cohort ||= Cohort.find_by(start_year: params[:cohort_id])
  end
end
