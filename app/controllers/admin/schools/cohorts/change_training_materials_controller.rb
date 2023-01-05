# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class ChangeTrainingMaterialsController < ::Admin::BaseController
        skip_after_action :verify_authorized
        skip_after_action :verify_policy_scoped
        before_action :set_school_and_cohort
        before_action :set_form, only: %i[confirm update]

        def show
          @core_induction_programme_choice_form = CoreInductionProgrammeChoiceForm.new
        end

        def confirm
          render :show unless @core_induction_programme_choice_form.valid?
        end

        def update
          update_training_materials
          set_success_message heading: "Training materials have been changed"
          redirect_to admin_school_cohorts_path
        end

      private

        def update_training_materials
          Induction::ChangeCoreInductionProgramme.call(school_cohort: SchoolCohort.find_by!(school: @school, cohort: @cohort),
                                                       core_induction_programme: @core_induction_programme_choice_form.core_induction_programme)
        end

        def set_school_and_cohort
          @cohort = ::Cohort.find_by(start_year: params[:id])
          @school = ::School.friendly.find(params[:school_id])
        end

        def set_form
          @core_induction_programme_choice_form = CoreInductionProgrammeChoiceForm.new(
            params.require(:core_induction_programme_choice_form).permit(:core_induction_programme_id),
          )
        end
      end
    end
  end
end
