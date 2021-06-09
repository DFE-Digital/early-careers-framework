# frozen_string_literal: true

module Demo
  class ParticipantValidationController < ApplicationController
    http_basic_authenticate_with name: Rails.application.config.demo_password, password: Rails.application.config.demo_password
    def new
      @form = DemoParticipantValidationForm.new
    end

    def create
      @form = DemoParticipantValidationForm.new(params.require(:demo_participant_validation_form).permit(:full_name, :trn, :nino))
      @form.dob = Date.new(params[:demo_participant_validation_form]["dob(1i)".to_sym].to_i, params[:demo_participant_validation_form]["dob(2i)".to_sym].to_i, params[:demo_participant_validation_form]["dob(3i)".to_sym].to_i)
      render :new and return unless @form.valid?

      @validation_result = ParticipantValidationService.new.validate(trn: @form.trn, nino: @form.nino, full_name: @form.full_name, dob: @form.dob)
    end
  end
end
