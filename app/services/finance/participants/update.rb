# frozen_string_literal: true

module Finance
  module Participants
    class Update
      def initialize(participant_profile)
        self.participant_profile = participant_profile
      end

      def call(attributes)
        ParticipantProfile.transaction do
          participant_profile.update!(attributes)
        end
      end

    private

      attr_accessor :participant_profile
    end
  end
end
