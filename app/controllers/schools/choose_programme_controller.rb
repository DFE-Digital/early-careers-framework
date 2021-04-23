# frozen_string_literal: true

class Schools::ChooseProgrammeController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :load_programme_form
  before_action :verify_programme_chosen, only: %i[advisory show]

  def advisory; end

  def show; end

  def create
    render :show and return unless @induction_choice_form.valid?

    session[:induction_choice_form] = @induction_choice_form.serializable_hash
    redirect_to action: :confirm_programme
  end

  def confirm_programme; end

  def save_programme
    cohort = Cohort.current
    school = current_user.induction_coordinator_profile.schools.first

    SchoolCohort.find_or_create_by!(
      cohort: cohort,
      school: school,
      induction_programme_choice: induction_programme_choice,
    )

    session.delete(:induction_choice_form)
    redirect_to success_schools_choose_programme_path
  end

  def success; end

private

  def verify_programme_chosen
    school = current_user.induction_coordinator_profile.schools.first
    redirect_to helpers.profile_dashboard_path(current_user) if school.chosen_programme?(Cohort.current)
  end

  def load_programme_form
    session_params = session[:induction_choice_form] || {}
    @induction_choice_form = InductionChoiceForm.new(session_params.merge(programme_choice_form_params))
  end

  def programme_choice_form_params
    return {} unless params.key?(:induction_choice_form)

    params.require(:induction_choice_form).permit(:programme_choice)
  end
end
