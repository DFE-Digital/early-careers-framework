# frozen_string_literal: true

module Admin::Participants
  class ValidationDataController < Admin::BaseController
    before_action :load_participant_profile
    before_action :load_validation_data_form, except: :validate_details
    before_action :validate_save_and_redirect, except: :validate_details

    def full_name; end

    def trn; end

    def date_of_birth; end

    def nino; end

    def validate_details
      generate_status_message(validate_participant!)
      redirect_to validation_page
    end

  private

    def validate_participant!
      return unless validation_data.present? && validation_data.can_validate_participant?
      ActiveRecord::Base.transaction do
        @participant_profile.ecf_participant_eligibility&.destroy
        # this returns either nil, false on failure or an ECFParticipantEligibility record on success
        Participants::ParticipantValidationForm.call(@participant_profile)
      end
    end

    def validate_save_and_redirect
      if (request.put? || request.post?) && step_valid?
        save_validation_data!
        set_status_message_for_update

        redirect_to validation_page
      end
    end

    def save_validation_data!
      if current_action == :nino
        nino = @validation_data_form.formatted_nino
        validation_data.nino = nino.blank? ? nil : nino
      else
        validation_data[current_action] = @validation_data_form.send(current_action)
      end
      validation_data.save!
    end

    def set_status_message_for_update
      if validation_data.can_validate_participant?
        generate_status_message(validate_participant!)
      else
        set_success_message(content: "Validation information updated")
      end
    end

    def generate_status_message(validation_result)
      if validation_result.blank?
        set_important_message(content: "No match was found for these details")
      else
        set_success_message(content: "Details matched and eligibility determined")
      end
    end

    def validation_page
      admin_participant_path(@participant_profile, anchor: "validation-data")
    end

    def load_participant_profile
      @participant_profile = policy_scope(ParticipantProfile).find(params[:participant_id]).tap do |participant_profile|
        authorize participant_profile, :update?, policy_class: participant_profile.policy_class
      end
    end

    def validation_data
      @validation_data ||= @participant_profile.ecf_participant_validation_data || ECFParticipantValidationData.new(participant_profile: @participant_profile)
    end

    def current_action
      action_name.to_sym
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
      attrs.merge!(validation_data_form_params) unless request.get?
      attrs
    end

    def validation_data_form_params
      return {} unless params.key?(:admin_validation_data_form)

      params.require(:admin_validation_data_form).permit(:full_name, :trn, :date_of_birth, :nino)
    end
  end
end
