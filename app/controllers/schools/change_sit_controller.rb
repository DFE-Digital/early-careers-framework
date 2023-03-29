# frozen_string_literal: true

module Schools
  class ChangeSitController < ::Schools::BaseController
    skip_after_action :verify_authorized, :verify_policy_scoped
    before_action :set_form
    skip_before_action :ensure_school_user, only: :success
    skip_before_action :authenticate_user!, only: :success

    helper_method :has_multiple_schools?

    def name; end

    def set_name
      unless @induction_tutor_form.valid?(:full_name)
        return render :name
      end

      store_form
      redirect_to action: :email
    end

    def email; end

    def set_email
      unless @induction_tutor_form.valid?(:email)
        return render :email
      end

      store_form
      redirect_to action: :check_details
    end

    def check_details; end

    def confirm; end

    def save
      InductionTutors::Create.call(
        school: @induction_tutor_form.school,
        email: @induction_tutor_form.email,
        full_name: @induction_tutor_form.full_name,
      )
      redirect_to action: :success
    end

    def success
      session.delete(:induction_tutor_form)
      sign_out unless current_user&.schools&.any?
    end

  private

    def has_multiple_schools?
      current_user.schools.count > 1
    end

    def form_params
      return if params[:nominate_induction_tutor_form].blank?

      params.require(:nominate_induction_tutor_form).permit(:full_name, :email)
    end

    def set_form
      @induction_tutor_form = NominateInductionTutorForm.new(session[:induction_tutor_form])
      @induction_tutor_form.school_id ||= active_school.id
      @induction_tutor_form.assign_attributes(form_params) if form_params.present?
    end

    def store_form
      session[:induction_tutor_form] = @induction_tutor_form.serializable_hash
    end
  end
end
