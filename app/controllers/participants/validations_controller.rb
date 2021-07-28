# frozen_string_literal: true

module Participants
  class ValidationsController < ApplicationController
    before_action :set_form

    def do_you_know_your_trn
      if request.put?
        if @form.valid?
          redirect_to participants_validation_have_you_changed_your_name_path
        end
      end
    end

    def have_you_changed_your_name
      if request.put?
        if @form.valid?
          redirect_to root_path
        end
      end
    end

    def tell_us_your_details
      if request.put?
        if @form.valid?
          redirect_to root_path
        end
      end
    end

  private

    def set_form
      @form = ParticipantValidationForm.new(form_params)
      @form.step ||= action_name
    end

    def form_params
      params.fetch(:participants_participant_validation_form, {}).permit(
        :do_you_know_your_trn_choice,
        :step
      )
    end

    # include Multistep::Controller
    #
    # form Participants::ParticipantValidationForm, as: :participant_validation_form
    #
    # setup_form
    #
    # result as: :participant_validation
    #
    # abandon_journey_path do
    #   root_path
    # end
  end
end
