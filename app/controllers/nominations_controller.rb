# frozen_string_literal: true

class NominationsController < ApplicationController
  before_action :load_nomination_request_form, except: %i[choose_location index resend_email_after_link_expired link_expired already_nominated]

  def index
    @nomination_email = NominationEmail.find_by(token: params[:token])
    @token = params[:token]

    if @nomination_email.nil?
      redirect_to link_invalid_nominations_path
    elsif @nomination_email.nomination_expired?
      redirect_to link_expired_nominations_path(school_id: @nomination_email.school_id)
    elsif @nomination_email.tutor_already_nominated?
      redirect_to already_nominated_nominations_path
    else
      load_nominate_induction_tutor_form
      @school = @nomination_email.school
    end
  end

  def create_school_lead_nomination
    load_nominate_induction_tutor_form

    if User.exists?(email: @nominate_induction_tutor_form.email)
      redirect_to already_associated_with_another_school_nominations_path
    else
      @nominate_induction_tutor_form.save!
      session.delete(:nominate_induction_tutor_form)
      redirect_to nominate_school_lead_success_nominations_path
    end
  end

  def link_expired
    @school_id = params[:school_id]
  end

  def resend_email_after_link_expired
    school = School.find(params[:resend_email_after_link_expired][:school_id])
    InviteSchools.new.resend_school_invitation(school)
    redirect_to success_nominations_path
  end

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
      redirect_to choose_school_nominations_path
    else
      @local_authorities = LocalAuthority.all
      render :choose_location
    end
  end

  def choose_school; end

  def receive_school
    render :choose_school and return unless @nomination_request_form.valid?(:school)

    session[:nomination_request_form] = @nomination_request_form.serializable_hash

    if !@nomination_request_form.school.eligible?
      redirect_to not_eligible_nominations_path
    elsif @nomination_request_form.school.fully_registered?
      redirect_to already_renominated_nominations_path
    elsif @nomination_request_form.school.partially_registered?
      redirect_to limit_reached_nominations_path
    else
      redirect_to review_nominations_path
    end
  end

  def not_eligible; end

  def already_renominated; end

  def limit_reached; end

  def review; end

  def already_associated_with_another_school; end

  def already_nominated; end

  def nominate_school_lead_success; end

  def create
    @nomination_request_form.save!
    session.delete(:nomination_request_form)

    redirect_to success_nominations_path
  end

  def success; end

private

  def email_address_already_used_for_another_school?; end

  def load_nominate_induction_tutor_form
    @nominate_induction_tutor_form = ::NominateInductionTutorForm.new(session[:nominate_induction_tutor_form])
    @nominate_induction_tutor_form.assign_attributes(nominate_induction_tutor_form_params)
  end

  def nominate_induction_tutor_form_params
    return {} unless params.key?(:nominate_induction_tutor_form)

    params.require(:nominate_induction_tutor_form).permit(:full_name, :email, :token)
  end

  def load_nomination_request_form
    @nomination_request_form = NominationRequestForm.new(session[:nomination_request_form])
    @nomination_request_form.assign_attributes(nomination_params)
  end

  def nomination_params
    return {} unless params.key?(:nomination_request_form)

    params.require(:nomination_request_form).permit(:school_id, :local_authority_id)
  end
end
