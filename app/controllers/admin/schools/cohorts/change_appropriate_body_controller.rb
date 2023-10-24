# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class ChangeAppropriateBodyController < ::Admin::BaseController
        skip_after_action :verify_authorized
        skip_after_action :verify_policy_scoped
        before_action :set_school_and_cohort, :set_school_cohort, :set_appropriate_body_options

        def show
          @change_appropriate_body_form = form_from_school_cohort
        end

        def update
          @change_appropriate_body_form = Admin::ChangeAppropriateBodyForm.new(params.require(:admin_change_appropriate_body_form).permit(:appropriate_body, :teaching_school_hub_id))

          if @change_appropriate_body_form.valid?
            # TODO: update appropriate body
            redirect_to admin_school_cohorts_path(@school)
          else
            render :show
          end
        end

      private

        def form_from_school_cohort
          if @school_cohort.appropriate_body&.body_type == "teaching_school_hub"
            Admin::ChangeAppropriateBodyForm.new(
              appropriate_body: "teaching_school_hub",
              teaching_school_hub_id: @school_cohort.appropriate_body_id,
            )
          else
            Admin::ChangeAppropriateBodyForm.new(
              appropriate_body: @school_cohort.appropriate_body_id,
            )
          end
        end

        def set_appropriate_body_options
          @national_appropriate_bodies = AppropriateBody.where(body_type: "national").active_in_year(@school_cohort.cohort.start_year)
          @teaching_school_hubs = AppropriateBody.where(body_type: "teaching_school_hub").active_in_year(@school_cohort.cohort.start_year)
        end

        def set_school_and_cohort
          @school = ::School.friendly.find params[:school_id]
          @cohort = ::Cohort.find_by start_year: params[:id]
        end

        def set_school_cohort
          @school_cohort ||= @school.school_cohorts.find(params[:id])
        end
      end
    end
  end
end
