# frozen_string_literal: true

class Nominations::ChooseHowToContinueController < ApplicationController
  before_action :check_token_status, only: :new

  def new
    @how_to_continue_form = NominateHowToContinueForm.new(token: token,
                                                          school: school,
                                                          cohort: cohort)
  end

  def create
    record_nomination_email_opened
    @how_to_continue_form = NominateHowToContinueForm.new(how_to_continue_form_params)
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

  def check_token_status
    if nomination_email.nil?
      redirect_to link_invalid_nominate_induction_coordinator_path
    elsif nomination_email.expired?
      redirect_to link_expired_nominate_induction_coordinator_path(school_id: nomination_email.school_id)
    elsif nomination_email.school.registered?
      redirect_to already_nominated_request_nomination_invite_path
    end
  end

  def token
    @token ||= params[:token]
  end

  def nomination_email
    @nomination_email ||= NominationEmail.find_by(token: token)
  end

  def school
    nomination_email&.school
  end

  def record_opt_out_state_and_redirect!
    opt_out = @how_to_continue_form.opt_out?

    if opt_out
      school.school_cohorts.find_or_create_by!(cohort: cohort) do |school_cohort|
        school_cohort.induction_programme_choice = :not_yet_known
        school_cohort.opt_out_of_updates = true
      end
      redirect_to choice_saved_path(token: @how_to_continue_form.token)
    else
      school_cohort = school.school_cohorts.for_year(cohort.start_year)
      school_cohort.update!(opt_out_of_updates: false) if school_cohort.present?

      redirect_to start_nomination_nominate_induction_coordinator_path(token: @how_to_continue_form.token)
    end
  end

  def how_to_continue_form_params
    params.require(:nominate_how_to_continue_form).permit(:how_to_continue, :token)
  end

  def record_nomination_email_opened
    NominationEmail
      .where(token: nomination_email.token, opened_at: nil)
      .update_all(opened_at: Time.zone.now)
  end

  def cohort
    Cohort.current
  end
end
