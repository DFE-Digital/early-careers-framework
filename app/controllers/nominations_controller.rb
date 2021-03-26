# frozen_string_literal: true

class NominationsController < ApplicationController
  before_action :load_nomination_request_form, except: %i[choose_location]

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
      redirect_to already_nominated_nominations_path
    elsif @nomination_request_form.school.partially_registered?
      redirect_to limit_reached_nominations_path
    else
      redirect_to review_nominations_path
    end
  end

  def not_eligible; end

  def already_nominated; end

  def limit_reached; end

  def review; end

  def create
    @nomination_request_form.save!
    session.delete(:nomination_request_form)

    redirect_to success_nominations_path
  end

  def success; end

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
