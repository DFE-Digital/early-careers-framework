# frozen_string_literal: true

class Schools::CoreProgramme::MaterialsController < Schools::BaseController
  before_action :set_school_cohort
  before_action :prevent_double_submission, only: %i[advisory info edit update]

  def advisory; end

  def info; end

  def show; end

  def edit
    @form = CoreInductionProgrammeChoiceForm.new
  end

  def update
    @form = CoreInductionProgrammeChoiceForm.new(
      params.require(:core_induction_programme_choice_form).permit(:core_induction_programme_id),
    )

    render :edit and return unless @form.valid?

    @school_cohort.update!(
      core_induction_programme_id: @form.core_induction_programme_id,
    )

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
