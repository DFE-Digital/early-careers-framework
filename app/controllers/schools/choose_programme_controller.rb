# frozen_string_literal: true

class Schools::ChooseProgrammeController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :load_programme_form
  before_action :verify_can_choose_programme, only: %i[show]

  def show
    if current_user.schools.count > 1
      @show_back_link = true
    end
  end

  def create
    render :show and return unless @induction_choice_form.valid?

    session[:induction_choice_form] = @induction_choice_form.serializable_hash
    redirect_to action: :confirm_programme
  end

  def confirm_programme; end

  def save_programme
    save_school_choice!

    session.delete(:induction_choice_form)

    redirect_to success_schools_choose_programme_path
  end

  def success
    render locals: { school_cohort: }
  end

private

  def verify_can_choose_programme
    return if school_cohort.new_record? || school_cohort.can_change_programme?

    redirect_to helpers.profile_dashboard_path(current_user)
  end

  def load_programme_form
    session_params = session[:induction_choice_form] || {}
    @induction_choice_form = InductionChoiceForm.new(
      session_params.merge(programme_choice_form_params).merge(school_cohort:),
    )
  end

  def save_school_choice!
    Induction::SetCohortInductionProgramme.call(school_cohort:,
                                                programme_choice: @induction_choice_form.programme_choice,
                                                opt_out_of_updates: @induction_choice_form.opt_out_choice_selected?)
  end

  def programme_choice_form_params
    return {} unless params.key?(:induction_choice_form)

    params.require(:induction_choice_form).permit(:programme_choice)
  end

  def school
    @school ||= active_school
  end

  def cohort
    @cohort ||= Cohort.find_by(start_year: params[:cohort_id])
  end

  def school_cohort
    @school_cohort ||= school.school_cohorts.find_or_initialize_by(cohort:)
  end
end
