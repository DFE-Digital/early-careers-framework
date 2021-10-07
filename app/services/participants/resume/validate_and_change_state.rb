# frozen_string_literal: true

module Participants
  module Resume
    module ValidateAndChangeState
      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileState.create!(participant_profile: user_profile, state: "active")
          user_profile.training_status_active!
        end
        user_profile
      end
    end
  end
end
