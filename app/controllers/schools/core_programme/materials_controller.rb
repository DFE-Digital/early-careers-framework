# frozen_string_literal: true

class Schools::CoreProgramme::MaterialsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :set_school_cohort

  def info; end
  def edit
    @form = CoreInductionProgrammeChoiceForm.new
  end

  def update
    @form = CoreInductionProgrammeChoiceForm.new(
      params.require(:core_induction_programme_choice_form).permit(:core_induction_programme_id)
    )

    render :edit and return unless @form.valid?

    @school_cohort.update!(
      core_induction_programme_id: @form.core_induction_programme_id
    )

    redirect_to action: :success
  end
end
