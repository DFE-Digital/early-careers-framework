# frozen_string_literal: true

module Admin
  module Participants
    class ChangeRelationshipController < Admin::BaseController
      include Wizard::Controller
      before_action :initialize_wizard
      skip_after_action :verify_policy_scoped

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
