# frozen_string_literal: true

class Nominations::NominateInductionCoordinatorController < ApplicationController
  include NominationEmailTokenConsumer

  before_action :load_nominate_induction_tutor_form, only: %i[full_name check_name email check_email check create]
  before_action :check_token_status, only: %i[start_nomination full_name email check]

  def start_nomination
    unless params[:continue]
      session.delete(:nominate_induction_tutor_form)
    end

    token = params[:token]
    load_nominate_induction_tutor_form
    @nominate_induction_tutor_form.token = token
    store_nominate_induction_tutor_form
  end

  def full_name; end

  def check_name
    if @nominate_induction_tutor_form.valid? :full_name
      store_nominate_induction_tutor_form
      redirect_to action: :email
    else
      render :full_name
    end
  end

  def email; end

  def check_email
    if @nominate_induction_tutor_form.valid? :email
      store_nominate_induction_tutor_form
      redirect_to action: :check
    elsif @nominate_induction_tutor_form.name_different?
      redirect_to action: :name_different
    elsif @nominate_induction_tutor_form.email_already_taken?
      redirect_to action: :email_used
    else
      render :email
    end
  end

  def check; end

  def create
    InductionTutors::Create.call(school: @nominate_induction_tutor_form.school,
                              email: @nominate_induction_tutor_form.email,
                              full_name: @nominate_induction_tutor_form.full_name)
    session.delete(:nominate_induction_tutor_form)

    redirect_to nominate_school_lead_success_nominate_induction_coordinator_path
  end

  def link_expired
    @school_id = params[:school_id]
  end

  def resend_email_after_link_expired
    nomination_request_form = build_nomination_request_form
    nomination_request_form.save!

    redirect_to success_request_nomination_invite_path
  rescue TooManyEmailsError
    redirect_to limit_reached_request_nomination_invite_path
  end

  def email_used; end

  def name_different; end

  def nominate_school_lead_success; end

private

  def load_nominate_induction_tutor_form
    @nominate_induction_tutor_form = ::NominateInductionTutorForm.new(session[:nominate_induction_tutor_form])
    @nominate_induction_tutor_form.assign_attributes(nominate_induction_tutor_form_params)
  end

  def nominate_induction_tutor_form_params
    return {} unless params.key?(:nominate_induction_tutor_form)

    params.require(:nominate_induction_tutor_form).permit(:full_name, :email, :token)
  end

  def build_nomination_request_form
    school = School.find(params[:resend_email_after_link_expired][:school_id])
    NominationRequestForm.new(
      local_authority_id: school.local_authority.id,
      school_id: school.id,
    )
  end

  def store_nominate_induction_tutor_form
    session[:nominate_induction_tutor_form] = @nominate_induction_tutor_form.serializable_hash
  end
end
