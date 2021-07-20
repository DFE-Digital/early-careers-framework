# frozen_string_literal: true

module Schools
  class Year2020Controller < ApplicationController
    include Pundit

    before_action :authenticate_user!
    before_action :ensure_school_user
    before_action :set_paper_trail_whodunnit
    after_action :verify_authorized

    layout "school_cohort"

    include Multistep::Controller

    skip_after_action :verify_authorized
    before_action :set_school_cohort

    form Year2020Form, as: :year_2020_form
    result as: :participant_profile

    abandon_journey_path do
      schools_dashboard_path
    end

    setup_form do |form|
      form.school_cohort_id = @school_cohort.id
      form.current_user_id = current_user.id
    end

  private

    def email_used_in_the_same_school?
      User.find_by(email: year_2020_form.email).school == year_2020_form.school_cohort.school
    end

    helper_method :email_used_in_the_same_school?

    def ensure_school_user
      raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.induction_coordinator?

      authorize(active_school, :show?) if active_school.present?
    end

    def active_school
      return if params[:school_id].blank?

      School.friendly.find(params[:school_id])
    end

    def active_cohort
      Cohort.find_or_create_by!(start_year: 2020) # QQQQ Add
    end

    def set_school_cohort
      @school = active_school
      @cohort = active_cohort

      @school_cohort = SchoolCohort.find_or_create_by!(
        cohort: @cohort,
        school: @school,
        induction_programme_choice: "core_induction_programme",
      )
    end
  end
end
