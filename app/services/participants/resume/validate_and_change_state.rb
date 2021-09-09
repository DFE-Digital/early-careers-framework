# frozen_string_literal: true

module Participants
  module Resume
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      def perform_action!
        ParticipantProfileState.create!(participant_profile: user_profile, state: "active")
        user_profile
      end
    end
  end
end
