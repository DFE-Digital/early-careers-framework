# frozen_string_literal: true

class Schools::PartnershipsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @school = current_user.induction_coordinator_profile.schools.first
    @partnership = @school.partnerships.unchallenged.find_by(cohort: cohort)

    if @partnership
      email = @partnership.partnership_notification_emails.order(:created_at).first
      if email.present? && !email.token_expired?
        @report_mistake_link = challenge_partnership_path(token: email.token)
        @mistake_link_expiry = email.token_expiry.strftime("%d/%m/%Y")
      end
    end
  end

private

  def cohort
    @cohort ||= Cohort.find_by(start_year: params[:cohort_id])
  end
end
