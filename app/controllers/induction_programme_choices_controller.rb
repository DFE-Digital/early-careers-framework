# frozen_string_literal: true

class InductionProgrammeChoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_induction_coordinator

  def show
    @programme_choices = [
      OpenStruct.new(id: "funded_training_provider", name: "Use a training provider funded by the Department for Education"),
      OpenStruct.new(id: "free_development_materials", name: "Use the free development materials"),
      OpenStruct.new(id: "design_our_own", name: "Design your own induction based on the Early Career Framework"),
      OpenStruct.new(id: "not_yet_known", name: "I don't know yet"),
    ]
  end

  def create
    # TODO: Register and Partner 262: Figure out how to update current year
    @cohort = Cohort.find_or_create_by!(start_year: 2020)
    @school = current_user.induction_coordinator_profile.schools.first

    @school_cohort = SchoolCohort.create!(
      cohort: @cohort, school: @school,
      induction_programme_choice: params[:choice]
    )

    if @school_cohort.not_yet_known?
      redirect_to :registrations_learn_options
    else
      redirect_to induction_programme_choices_path, notice: "Succesfully saved"
    end
  end

private

  def ensure_induction_coordinator
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.induction_coordinator?
  end
end
