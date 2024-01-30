# frozen_string_literal: true

class Schools::CoreProgramme::MaterialsController < Schools::BaseController
  before_action :set_school_cohort
  before_action :prevent_double_submission, only: %i[info edit update]

  def info; end

  def show; end

  def edit
    @form = CoreInductionProgrammeChoiceForm.new
  end

  def update
    @form = CoreInductionProgrammeChoiceForm.new(
      params.require(:core_induction_programme_choice_form).permit(:core_induction_programme_id),
    )

    unless @form.valid?
      track_validation_error(@form)
      render :edit
      return
    end

    @school_cohort.update!(
      core_induction_programme_id: @form.core_induction_programme_id,
    )

    unless @school_cohort.default_induction_programme&.core_induction_programme
      @school_cohort.default_induction_programme.update!(
        core_induction_programme_id: @form.core_induction_programme_id,
      )
    end

    redirect_to action: :success
  end

private

  def prevent_double_submission
    return if @school_cohort.core_induction_programme_id.blank?

    redirect_to action: :show
  end

  def set_school_cohort
    super
    authorize @school_cohort
  end
end
