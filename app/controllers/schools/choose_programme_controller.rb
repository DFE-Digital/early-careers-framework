# frozen_string_literal: true

class Schools::ChooseProgrammeController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :verify_programme_chosen, only: %i[advisory show]
  before_action :set_school_cohort, only: %[edit]

  def advisory; end


  def show
    @induction_choice_form = InductionChoiceForm.new
  end

  def create
    @induction_choice_form = InductionChoiceForm.new(params.require(:induction_choice_form).permit(:programme_choice))

    render :show and return unless @induction_choice_form.valid?

    cohort = Cohort.current
    school = current_user.induction_coordinator_profile.schools.first

    SchoolCohort.find_or_create_by!(
      cohort: cohort,
      school: school,
      induction_programme_choice: @induction_choice_form.programme_choice,
    )

    redirect_to helpers.profile_dashboard_url(current_user)
  end

<<<<<<< HEAD
private

  def verify_programme_chosen
    school = current_user.induction_coordinator_profile.schools.first
    redirect_to helpers.profile_dashboard_url(current_user) if school.chosen_programme?(Cohort.current)
  end
=======
  def edit; end
>>>>>>> No-op change training type page
end
