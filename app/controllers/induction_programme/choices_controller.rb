# frozen_string_literal: true

class InductionProgramme::ChoicesController < InductionProgramme::BaseController
  def show
    @programme_choices = [
      OpenStruct.new(id: "full_induction_programme", name: "Use a training provider funded by the Department for Education"),
      OpenStruct.new(id: "core_induction_programme", name: "Use the free development materials"),
      OpenStruct.new(id: "design_our_own", name: "Design your own induction based on the Early Career Framework"),
      OpenStruct.new(id: "not_yet_known", name: "I don't know yet"),
    ]
  end

  def create
    # TODO: Register and Partner 262: Figure out how to update current year
    @cohort = Cohort.find_or_create_by!(start_year: 2021)
    @school = current_user.induction_coordinator_profile.schools.first

    @school_cohort = SchoolCohort.create!(
      cohort: @cohort, school: @school,
      induction_programme_choice: params[:choice]
    )

    if @school_cohort.not_yet_known?
      redirect_to :registrations_learn_options
    elsif @school_cohort.full_induction_programme?
      redirect_to estimates_path
    else
      redirect_to choices_path, notice: "Succesfully saved"
    end
  end
end
