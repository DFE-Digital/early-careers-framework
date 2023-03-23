# frozen_string_literal: true

module Schools
  module AddParticipants
    class TransferController < BaseController
      before_action :initialize_wizard, except: :complete
      before_action :data_check, except: :complete

      def complete
        @profile = ParticipantProfile.find(params[:participant_profile_id])
        remove_session_data
      end

    private

      def data_check
        unless @wizard.found_participant_in_dqt? && @wizard.transfer?
          remove_session_data
          redirect_to abort_path
        end
      end

      def wizard_class
        TransferWizard
      end

      def default_step_name
        "joining-date"
      end
    end
  end
end
