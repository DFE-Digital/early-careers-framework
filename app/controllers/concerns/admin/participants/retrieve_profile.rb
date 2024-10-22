# frozen_string_literal: true

module Admin
  module Participants
    module RetrieveProfile
      extend ActiveSupport::Concern

      included do
        before_action :retrieve_participant_profile
      end

      def retrieve_participant_profile
        @participant_profile = policy_scope(scope).find(params[:participant_id]).tap do |participant_profile|
          authorize participant_profile, :show?, policy_class: participant_profile.policy_class
        end
      end

    private

      def scope
        return ParticipantProfile unless NpqApiEndpoint.disabled?

        ParticipantProfile.ecf
      end
    end
  end
end
