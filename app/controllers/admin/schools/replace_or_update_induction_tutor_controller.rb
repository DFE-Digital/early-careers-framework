# frozen_string_literal: true

module Admin
  class Schools::ReplaceOrUpdateInductionTutorController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
    before_action :set_school

    def show
      @replace_or_update_tutor_form = ReplaceOrUpdateTutorForm.new
    end

    def choose
      @replace_or_update_tutor_form = ReplaceOrUpdateTutorForm.new(replace_or_update_params)
      if @replace_or_update_tutor_form.valid?
        if @replace_or_update_tutor_form.replace_tutor?
          redirect_to new_admin_school_induction_coordinator_path(@school)
        else
          redirect_to edit_admin_school_induction_coordinator_path(@school, school_induction_tutor)
        end
      else
        render :show
      end
    end

  private

    def set_school
      @school = School.find params[:school_id]
    end

    def school_induction_tutor
      @school.induction_coordinators.first
    end

    def replace_or_update_params
      params.require(:replace_or_update_tutor_form).permit(:choice)
    end
  end
end
