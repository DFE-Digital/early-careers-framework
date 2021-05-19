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
      # render :new and return unless @nominate_induction_tutor_form.valid?

      if @nominate_induction_tutor_form.valid?
        if email_already_used?(@nominate_induction_tutor_form.email)
          @email_address = @nominate_induction_tutor_form.email
          @another_school = school_using_this_email(@email_address)
          render "email_used"
        else
          create_school_induction_tutor!(school: @school,
                                         email: @nominate_induction_tutor_form.email,
                                         full_name: @nominate_induction_tutor_form.full_name)
          set_success_message(content: "New induction tutor added. They will get an email with next steps.", title: "Success")
          redirect_to admin_school_path(@school)
        end
      else
        render :new
      end
    end

    def create_school_induction_tutor!(school:, email:, name:)
      school.induction_coordinators.first.destroy! if school.induction_coordinators.first

      InductionCoordinatorProfile.create_induction_coordinator(
        name,
        email,
        school,
        Rails.application.routes.url_helpers.root_url(host: Rails.application.config.domain),
      )
    end

    def school_using_this_email(email)
      User.find_by(email: email).schools.first
    end

    def email_already_used?(email)
      User.exists?(email: email)
    end

    #   @nominate_induction_tutor_form.save!
    #   set_success_message(content: "New induction tutor added. They will get an email with next steps.", title: "Success")
    #   redirect_to admin_school_path(@school)
    # rescue UserExistsError
    #   redirect_to email_used_admin_school_induction_coordinators_path
    # end

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
