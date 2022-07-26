# frozen_string_literal: true

module Schools
  class CohortsController < BaseController
    include AppropriateBodySelection::Controller

    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :set_school_cohort

    def show
      if @school_cohort.can_change_programme?
        redirect_to(schools_dashboard_path) and return
      end

      render "programme_choice"
    end

    def roles
      @hide_button = true if params[:info]
    end

    def add_appropriate_body
      if @school_cohort.appropriate_body.present?
        redirect_to schools_dashboard_path
      else
        start_appropriate_body_selection
      end
    end

  private

    def start_appropriate_body_selection
      super from_path: schools_dashboard_path,
            submit_action: :save_appropriate_body,
            school_name: @school.name,
            ask_appointed: false
    end

    def save_appropriate_body
      Induction::SetSchoolCohortAppropriateBody.call(school_cohort: @school_cohort,
                                                     appropriate_body_id: appropriate_body_form.body_id,
                                                     appropriate_body_appointed: appropriate_body_form.body_appointed,
                                                     update_induction_records: true)
      redirect_to schools_dashboard_path
    end
  end
end
