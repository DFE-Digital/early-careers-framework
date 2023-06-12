# frozen_string_literal: true

module Admin
  module Participants
    class ChangeRelationshipController < Admin::BaseController
      include Wizard::Controller
      before_action :initialize_wizard

    private

      def wizard
        @wizard ||=  wizard_class.new(participant_profile:,
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
        ChangeRelationshipWizard
      end

      def default_step_name
        "reason-for-change"
      end

      def abort_path
      end
    end
  end
end
