# frozen_string_literal: true

class Nominations::ChooseHowToContinueController < ApplicationController
  include NominationEmailTokenConsumer

  before_action :check_token_status, only: :new

  def new
    @how_to_continue_form = NominateHowToContinueForm.new(token: token,
                                                          school: school,
                                                          cohort: cohort)
  end

  def create
    @how_to_continue_form = NominateHowToContinueForm.new(how_to_continue_form_params)
    record_nomination_email_opened

    if @how_to_continue_form.valid?
      record_opt_out_state_and_redirect!
    else
      @how_to_continue_form.school = school
      @how_to_continue_form.cohort = cohort
      render :new
    end
  end

  def choice_saved
    @cohort = cohort
    @school = school
    render "shared/choice_saved_no_early_career_teachers"
  end

private

  def record_opt_out_state_and_redirect!
    opt_out = @how_to_continue_form.opt_out?

    if opt_out
      school.school_cohorts.find_or_create_by!(cohort: cohort) do |school_cohort|
        school_cohort.induction_programme_choice = :not_yet_known
        school_cohort.opt_out_of_updates = true
      end
      redirect_to choice_saved_path(token: @how_to_continue_form.token)
    else
      school_cohort = school.school_cohorts.for_year(cohort.start_year).first
      school_cohort.update!(opt_out_of_updates: false) if school_cohort.present?

      redirect_to start_nomination_nominate_induction_coordinator_path(token: @how_to_continue_form.token)
    end
  end

  def how_to_continue_form_params
    form_params = params.require(:nominate_how_to_continue_form).permit(:how_to_continue, :token)
    @token = form_params[:token]
    form_params
  end

  def cohort
    Cohort.current
  end
end
