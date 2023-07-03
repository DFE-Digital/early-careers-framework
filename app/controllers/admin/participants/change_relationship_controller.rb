# frozen_string_literal: true

module Admin
  module Participants
    class ChangeRelationshipController < Admin::BaseController
      include JourneyWizard::Controller

      before_action :initialize_wizard
      skip_after_action :verify_policy_scoped

      # override the basic update to handle flash messages
      def update
        if wizard.form.valid?
          wizard.save!
          # enable flash messages for admin wizards with no "complete" page
          if wizard.complete?
            if wizard.error_message.present?
              set_important_message(content: wizard.error_message, heading: "The relationship has not been changed")
            else
              set_success_message(content: "The relationship has been successfully changed", title: "Success")
            end
          end
          redirect_to wizard.next_step_path
          remove_session_data if wizard.complete?
        else
          render wizard.current_step
        end
      end

    private

      def wizard
        @wizard ||= wizard_class.new(participant_profile:,
                                     request:,
                                     current_user:,
                                     data_store:,
                                     current_step: step_name,
                                     default_step_name:,
                                     submitted_params:)
      end

      def data_store
        @data_store ||= FormData::ChangeParticipantRelationshipStore.new(session:, form_key: wizard_class.session_key)
      end

      def wizard_class
        ::Admin::Participants::ChangeRelationship::ChangeRelationshipWizard
      end

      def default_step_name
        :reason_for_change
      end

      def abort_path
        if participant_profile.present?
          admin_participant_path(participant_id: participant_profile)
        else
          admin_participants_path
        end
      end

      def participant_profile
        @participant_profile ||= ParticipantProfile.find(params[:id])
        authorize @participant_profile, policy_class: @participant_profile.policy_class
      end
    end
  end
end
