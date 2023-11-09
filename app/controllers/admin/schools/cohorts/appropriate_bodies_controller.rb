# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class AppropriateBodiesController < Admin::BaseController
        skip_after_action :verify_policy_scoped
        before_action :set_school_cohort
        before_action -> { authorize school_cohort, :change_appropriate_body? }, only: %i[edit update]

        def edit
          @form = Schools::Cohorts::AppropriateBodies::UpdateForm.new(school_cohort:)
        end

        def update
          @form = Schools::Cohorts::AppropriateBodies::UpdateForm.new(update_params)

          if @form.valid?
            @form.save!
            set_success_message heading: "#{@school_cohort.start_year} cohort's appropriate body updated to #{@school_cohort.appropriate_body.name}"
            redirect_to admin_school_cohorts_path(school)
          else
            render :edit
          end
        end

      private

        def set_school_cohort
          @school = School.friendly.find(params[:school_id])
          @school_cohort = @school.school_cohorts.for_year(params[:cohort_id]).first
        end
        attr_reader :school, :school_cohort

        helper_method :school, :school_cohort

        def update_params
          params.require(:admin_schools_cohorts_appropriate_bodies_update_form)
                .permit(:appropriate_body_id, :teaching_school_hub_id)
                .merge(school_cohort:)
        end
      end
    end
  end
end
