# frozen_string_literal: true

module Admin
  class Schools::InductionCoordinatorsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
    before_action :set_school

    def new
      @induction_tutor_form = NominateInductionTutorForm.new
    end

    def create
      @induction_tutor_form = NominateInductionTutorForm.new(tutor_form_params)

      if @induction_tutor_form.valid?
        CreateInductionTutor.call(school: @school,
                                  email: @induction_tutor_form.email,
                                  full_name: @induction_tutor_form.full_name)

        set_success_message(content: "New induction tutor added. They will get an email with next steps.", title: "Success")
        redirect_to admin_school_path(@school)
      elsif @induction_tutor_form.email_already_taken?
        render_email_used_page(email: @induction_tutor_form.email,
                               action_path: new_admin_school_induction_coordinator_path(@school))
      else
        render :new
      end
    end

    def edit
      @induction_tutor_form = NominateInductionTutorForm.new(school_induction_tutor_attributes)
    end

    def update
      @induction_tutor_form = NominateInductionTutorForm.new(school_induction_tutor_attributes.merge(tutor_form_params))

      if @induction_tutor_form.valid?
        @school.induction_tutor.update!(full_name: @induction_tutor_form.full_name,
                                       email: @induction_tutor_form.email)
        set_success_message(content: "Induction tutor details updated", title: "Success")
        redirect_to admin_school_path(@school)
      elsif @induction_tutor_form.email_already_taken?
        render_email_used_page(email: @induction_tutor_form.email,
                               action_path: edit_admin_school_induction_coordinator_path(@school, @school.induction_tutor))
      else
        render :edit
      end
    end

  private

    def set_school
      @school = School.find params[:school_id]
    end

    def school_induction_tutor_attributes
      user = @school.induction_tutor
      if user
        {
          user_id: user.id,
          email: user.email,
          full_name: user.full_name,
        }
      else
        {}
      end
    end

    def school_using_this_email(email)
      User.find_by(email: email).schools.first
    end

    def render_email_used_page(email:, action_path:)
      @email_address = email
      @another_school = school_using_this_email(email)
      @action_path = action_path
      render "email_used"
    end

    def tutor_form_params
      params.require(:tutor_details).permit(:full_name, :email)
    end
  end
end
