# frozen_string_literal: true

class Nominations::RequestNominationInviteController < ApplicationController
  before_action :load_nomination_request_form, except: %i[resend_email choose_location]

  def resend_email; end

  def choose_location
    @local_authorities = LocalAuthority.all
    unless params[:continue]
      session.delete(:nomination_request_form)
    end
    load_nomination_request_form
  end

  def receive_location
    if @nomination_request_form.valid?(:local_authority)
      session[:nomination_request_form] = @nomination_request_form.serializable_hash
      redirect_to choose_school_request_nomination_invite_path
    else
      track_validation_error(@nomination_request_form)
      @local_authorities = LocalAuthority.all
      render :choose_location
    end
  end

  def choose_school; end

  def receive_school
    unless @nomination_request_form.valid?(:school)
      track_validation_error(@nomination_request_form)
      render :choose_school
      return
    end

    session[:nomination_request_form] = @nomination_request_form.serializable_hash

    if !@nomination_request_form.school.can_access_service?
      redirect_to not_eligible_request_nomination_invite_path
    elsif @nomination_request_form.reached_email_limit.present?
      redirect_to limit_reached_request_nomination_invite_path
    else
      redirect_to review_request_nomination_invite_path
    end
  end

  def not_eligible; end

  def already_nominated; end

  def limit_reached
    @limit = @nomination_request_form.reached_email_limit
  end

  def review; end

  def create
    @nomination_request_form.save!
    session[:nomination_request_school_email] = @nomination_request_form.school.primary_contact_email
    session.delete(:nomination_request_form)

    redirect_to success_request_nomination_invite_path
  rescue TooManyEmailsError
    redirect_to limit_reached_request_nomination_invite_path
  end

  def success
    @school_email = session[:nomination_request_school_email]
  end

private

  def load_nomination_request_form
    @nomination_request_form = NominationRequestForm.new(session[:nomination_request_form])
    @nomination_request_form.assign_attributes(nomination_params)
  end

  def nomination_params
    return {} unless params.key?(:nomination_request_form)

    params.require(:nomination_request_form).permit(:school_id, :local_authority_id)
  end
end
