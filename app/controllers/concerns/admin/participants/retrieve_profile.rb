# frozen_string_literal: true

module Admin
  module Participants
    module RetrieveProfile
      extend ActiveSupport::Concern

      included do
        before_action :retrieve_participant_profile
      end

      def retrieve_participant_profile
        @participant_profile = policy_scope(ParticipantProfile).find(params[:participant_id]).tap do |participant_profile|
          authorize participant_profile, :show?, policy_class: participant_profile.policy_class
        end
      end
    end
  end
end
