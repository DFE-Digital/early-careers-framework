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
      set_success_message(content: "New Induction tutor has been created", title: "Success")
      redirect_to admin_school_path(@school)
    rescue UserExistsError
      redirect_to email_used_admin_school_induction_coordinators_path
    end

  private

    def set_school
      @school = School.find params[:school_id]
    end

    def form_params
      params.require(:nominate_induction_tutor_form).permit(:full_name, :email)
    end
  end
end
