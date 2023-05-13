# frozen_string_literal: true

class Schools::ChooseProgrammeController < Schools::BaseController
  include AppropriateBodySelection::Controller

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  skip_before_action :redirect_to_setup_cohort

  before_action :load_programme_form
  before_action :verify_can_choose_programme, only: %i[show]

  def show
    if current_user.schools.count > 1
      @show_back_link = true
    end
  end

  def create
    render :show and return unless @induction_choice_form.valid?

    save_induction_choice_form
    redirect_to action: :confirm_programme
  end

  def appropriate_body_type; end

  def confirm_programme; end

  def choose_appropriate_body
    if needs_to_choose_appropriate_body?
      start_appropriate_body_selection
    else
      save_programme
    end
  end

  def success
    render locals: { school_cohort:, continue: add_participant_after_complete }
  end

private

  delegate :add_participant_after_complete, to: :@induction_choice_form

  def save_programme
    save_school_choice!

    session.delete(:induction_choice_form)
    redirect_to success_schools_choose_programme_path(induction_choice_form: { add_participant_after_complete: })
  end

  def save_induction_choice_form
    session[:induction_choice_form] = @induction_choice_form.serializable_hash
  end

  def needs_to_choose_appropriate_body?
    @induction_choice_form.programme_choice != :no_early_career_teachers
  end

  def start_appropriate_body_selection
    super from_path: url_for(action: :create),
          submit_action: :save_programme,
          school_name: school.name
  end

  def verify_can_choose_programme
    return if school_cohort.new_record? || school_cohort.can_change_programme?

    redirect_to helpers.choose_role_path
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
    if needs_to_choose_appropriate_body?
      Induction::SetSchoolCohortAppropriateBody.call(school_cohort:,
                                                     appropriate_body_id: appropriate_body_form.body_id,
                                                     appropriate_body_appointed: appropriate_body_form.body_appointed?)
    end
  end

  def programme_choice_form_params
    return {} unless params.key?(:induction_choice_form)

    params.require(:induction_choice_form).permit(:programme_choice, :add_participant_after_complete)
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
