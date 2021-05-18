# frozen_string_literal: true

module Admin
  class Schools::InductionCoordinatorsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
    before_action :set_school

    def email_used; end

    def new
      @nominate_induction_tutor_form = NominateInductionTutorForm.new
    end

    def create
      @nominate_induction_tutor_form = NominateInductionTutorForm.new(
        form_params.merge(school_id: params[:school_id]),
      )
      render :new and return unless @nominate_induction_tutor_form.valid?

      @nominate_induction_tutor_form.save!
      set_success_message(content: "New induction tutor added. They will get an email with next steps.", title: "Success")
      redirect_to admin_school_path(@school)
    rescue UserExistsError
      redirect_to email_used_admin_school_induction_coordinators_path
    end

    def choose_replace_or_update
      @replace_or_update_tutor_form = ReplaceOrUpdateTutorForm.new
    end

    def replace_or_update
      @replace_or_update_tutor_form = ReplaceOrUpdateTutorForm.new(replace_or_update_params)
      if @replace_or_update_tutor_form.valid?
        if @replace_or_update_tutor_form.replace_tutor?
          redirect_to new_admin_school_induction_coordinator_path(@school)
        else
          redirect_to edit_admin_school_induction_coordinator_path(id: @school.id)
        end
      else
        render "choose_replace_or_update"
      end
    end

    def edit
      @induction_tutor = school_induction_tutor
    end

    def update
      @induction_tutor = school_induction_tutor
      if @induction_tutor.update(form_params)
        set_success_message(content: "Induction tutor details updated", title: "Success")
        redirect_to admin_school_path(@school)
      else
        render :edit
      end
    end

  private

    def set_school
      @school = School.find params[:school_id]
    end

    def school_induction_tutor
      @school.induction_coordinators.first
    end

    def form_params
      params.require(:tutor_details).permit(:full_name, :email)
    end

    def replace_or_update_params
      params.require(:replace_or_update_tutor_form).permit(:choice)
    end
  end
end
