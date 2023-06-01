# frozen_string_literal: true

module Schools
  module Cohorts
    class AppropriateBodyController < BaseController
      include AppropriateBodySelection::Controller

      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      before_action :set_school_cohort

      def add
        if @school_cohort.appropriate_body.present?
          redirect_to schools_dashboard_path
        else
          start_appropriate_body_selection
        end
      end

      def change
        start_appropriate_body_selection(preconfirmation: true)
      end

      def confirm
        @confirmation_type = params[:confirmation_type]
      end

    private

      def start_appropriate_body_selection(preconfirmation: false)
        super action_name:,
              from_path: schools_dashboard_path,
              submit_action: :save_appropriate_body,
              school_name: @school.name,
              ask_appointed: false,
              preconfirmation:,
              cohort_start_year: @cohort.start_year
      end

      def save_appropriate_body
        Induction::SetSchoolCohortAppropriateBody.call(school_cohort: @school_cohort,
                                                       appropriate_body_id: appropriate_body_form.body_id,
                                                       appropriate_body_appointed: appropriate_body_form.body_appointed)

        redirect_to url_for({ action: :confirm, confirmation_type: appropriate_body_action_name })
      end
    end
  end
end
