# frozen_string_literal: true

class SupportController < ApplicationController
  before_action :authenticate_user!

  def new
    @form = SupportForm.new(new_params)
  end

  def create
    @form = SupportForm.new(create_params)

    if @form.valid? && @form.save
      redirect_to support_confirmation_path
    else
      track_validation_error(@form)
      render :new
    end
  end

private

  attr_reader :form

  helper_method :subject, :form

  def subject
    params[:subject]
  end

  def participant_profile_id
    params[:participant_profile_id]
  end

  def new_params
    {
      participant_profile_id:,
      school_id: params[:school_id],
      cohort_year: params[:cohort_year],
      current_user:,
      subject:,
    }
  end

  def create_params
    params.require(:support_form).permit(:subject, :participant_profile_id, :school_id, :cohort_year, :message).merge(current_user:)
  end
end
