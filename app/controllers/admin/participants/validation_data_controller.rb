# frozen_string_literal: true

module Admin::Participants
  class ValidationDataController < Admin::BaseController
    include RetrieveProfile

    before_action :load_validation_data_form
    before_action :check_can_update_validation_data, if: -> { request.put? || request.post? }
    before_action :save_and_redirect

    def show
      @participant_presenter = Admin::ParticipantPresenter.new(@participant_profile)

      add_breadcrumb(
        school.name,
        admin_school_participants_path(school),
      )
    end

    def full_name; end

    def trn; end

    def date_of_birth; end

    def nino; end

  private

    def school
      @school ||= @participant_profile.school
    end

    def save_and_redirect
      if (request.put? || request.post?) && step_valid?
        save_validation_data!
        set_success_message(content: "Validation information updated")

        redirect_to validation_page
      end
    end

    def save_validation_data!
      if current_action == :nino
        nino = @validation_data_form.formatted_nino
        validation_data.nino = nino.presence
      else
        validation_data[current_action] = @validation_data_form.send(current_action)
      end
      validation_data.save!
    end

    def validation_page
      admin_participant_validation_data_path(@participant_profile)
    end

    def validation_data
      @validation_data ||= @participant_profile.ecf_participant_validation_data || ECFParticipantValidationData.new(participant_profile: @participant_profile)
    end

    def current_action
      action_name.to_sym
    end

    def check_can_update_validation_data
      unless policy(@participant_profile).update_validation_data?
        set_important_message(content: "You cannot update the validation data for this participant")
        redirect_to validation_page
      end
    end

    def step_valid?
      @validation_data_form.valid? current_action
    end

    def load_validation_data_form
      @validation_data_form = Admin::ValidationDataForm.new(build_form_data)
    end

    def build_form_data
      attrs = {
        participant_profile_id: validation_data.participant_profile_id,
        trn: validation_data.trn,
        full_name: validation_data.full_name,
        date_of_birth: validation_data.date_of_birth,
        nino: validation_data.nino,
      }
      attrs.merge!(validation_data_form_params) unless request.get? || request.head?
      attrs
    end

    def validation_data_form_params
      return {} unless params.key?(:admin_validation_data_form)

      params.require(:admin_validation_data_form).permit(:full_name, :trn, :date_of_birth, :nino)
    end
  end
end
