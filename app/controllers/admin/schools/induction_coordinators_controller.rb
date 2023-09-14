# frozen_string_literal: true

module Admin
  class Schools::InductionCoordinatorsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
    before_action :set_school

    attr_reader :school

    def new
      @induction_tutor_form = NominateInductionTutorForm.new(school:)
    end

    def create
      @induction_tutor_form = NominateInductionTutorForm.new(school:, **tutor_form_params)
      if @induction_tutor_form.valid?(%i[full_name email])
        @induction_tutor_form.save!
        set_success_message(content: "New induction tutor added. They will get an email with next steps.", title: "Success")
        redirect_to admin_school_path(school)
      else
        render :new
      end
    end

    def edit
      @induction_tutor_form = EditInductionTutorForm.new(school_induction_tutor_attributes)
    end

    def update
      @induction_tutor_form = EditInductionTutorForm.new(school_induction_tutor_attributes.merge(tutor_form_params))

      if @induction_tutor_form.save
        set_success_message(content: "Induction tutor details updated", title: "Success")
        redirect_to admin_school_path(school)
      else
        render :edit
      end
    end

  private

    def set_school
      @school = School.friendly.find params[:school_id]
    end

    def school_induction_tutor_attributes
      {
        induction_tutor: school.induction_tutor,
        email: school.induction_tutor&.email,
        full_name: school.induction_tutor&.full_name,
      }.compact
    end

    def tutor_form_params
      params.require(:tutor_details).permit(:full_name, :email)
    end
  end
end
