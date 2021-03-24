# frozen_string_literal: true

class NominationsController < ApplicationController
  before_action :load_nomination_form, except: %i[choose_location]

  def choose_location
    @local_authorities = LocalAuthority.all
    unless params[:continue]
      session.delete(:nomination_form)
    end
    load_nomination_form
  end

  def receive_location
    render :choose_location and return unless @nomination_form.valid?(:local_authority)

    session[:nomination_form] = @nomination_form.serializable_hash
    redirect_to choose_school_nominations_path
  end

  def choose_school; end

  def receive_school
    render :choose_school and return unless @nomination_form.valid?(:school)

    session[:nomination_form] = @nomination_form.serializable_hash
    if @nomination_form.school.eligible?
      redirect_to review_nominations_path
    else
      redirect_to not_eligible_nominations_path
    end
  end

  def not_eligible; end

  def review; end

  def create
    @nomination_form.save!
    session.delete(:nomination_form)

    redirect_to success_nominations_path
  end

  def success; end

private

  def load_nomination_form
    @nomination_form = NominationForm.new(session[:nomination_form])
    @nomination_form.assign_attributes(nomination_params)
  end

  def nomination_params
    return {} unless params.key?(:nomination_form)

    params.require(:nomination_form).permit(:school_id, :local_authority_id)
  end
end
