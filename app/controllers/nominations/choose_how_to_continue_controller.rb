# frozen_string_literal: true

class Nominations::ChooseHowToContinueController < ApplicationController
  include SchoolAccessTokenConsumer

  before_action :check_token_status, only: :new

  def new
    @how_to_continue_form = NominateHowToContinueForm.new(
      school: access_token.school,
      cohort: cohort,
    )
  end

  def create
    @how_to_continue_form = NominateHowToContinueForm.new(how_to_continue_form_params)
    @how_to_continue_form.school = access_token.school

    associated_email_records.each do |email_record|
      email_record.actioned!(override: false)
    end

    if @how_to_continue_form.valid?
      record_opt_out_state_and_redirect!
    else
      @how_to_continue_form.cohort = cohort
      render :new
    end
  end

  def choice_saved
    @cohort = cohort
    @school = access_token.school
    render "shared/choice_saved_no_early_career_teachers"
  end

private

  def check_token_status
    if access_token.nil?
      redirect_to link_invalid_nominate_induction_coordinator_path
    elsif access_token.expired?
      redirect_to link_expired_nominate_induction_coordinator_path(school_id: access_token.school_id)
    elsif access_token.school.registered?
      redirect_to already_nominated_request_nomination_invite_path
    end
  end

  def record_opt_out_state_and_redirect!
    school = @how_to_continue_form.school

    if @how_to_continue_form.opt_out?
      school.school_cohorts.find_or_create_by!(cohort: cohort) do |school_cohort|
        school_cohort.induction_programme_choice = :no_early_career_teachers
        school_cohort.opt_out_of_updates = true
      end
      redirect_to choice_saved_path
    else
      school_cohort = school.school_cohorts.for_year(cohort.start_year).first
      school_cohort.update!(opt_out_of_updates: false) if school_cohort.present?

      redirect_to start_nomination_nominate_induction_coordinator_path
    end
  end

  def how_to_continue_form_params
    params.require(:nominate_how_to_continue_form).permit(:how_to_continue)
  end

  def cohort
    Cohort.current
  end
end
