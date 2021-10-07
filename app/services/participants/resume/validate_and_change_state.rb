# frozen_string_literal: true

module Participants
  module Resume
    module ValidateAndChangeState
      def perform_action!
        ParticipantProfileState.create!(participant_profile: user_profile, state: "active")
        user_profile.update!(training_status: "active")
        user_profile
      end
    end
  end
end
