# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class ChangeProgrammeController < ::Admin::BaseController
        skip_after_action :verify_authorized
        skip_after_action :verify_policy_scoped
        before_action :set_school_and_cohort
        before_action :set_induction_choice_form, only: %i[confirm update]

        def show
          @induction_choice_form = InductionChoiceForm.new
          @induction_choice_form.school_cohort = school_cohort
        end

        def confirm
          render :show unless @induction_choice_form.valid?
        end

        def update
          Induction::ChangeCohortInductionProgramme.call(school_cohort:,
                                                         programme_choice: @induction_choice_form.programme_choice)

          set_success_message heading: "Induction programme has been changed"
          redirect_to admin_school_cohorts_path
        end

      private

        def set_induction_choice_form
          @induction_choice_form = InductionChoiceForm.new(params.require(:induction_choice_form).permit(:programme_choice))
          @induction_choice_form.school_cohort = school_cohort
        end

        def set_school_and_cohort
          @school = ::School.friendly.find params[:school_id]
          @cohort = ::Cohort.find_by start_year: params[:id]
        end

        def school_cohort
          @school_cohort ||= @school.school_cohorts.find_or_initialize_by(cohort: @cohort)
        end
      end
    end
  end
end
