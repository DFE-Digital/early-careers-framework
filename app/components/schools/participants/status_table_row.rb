# frozen_string_literal: true

module Schools
  module Participants
    class StatusTableRow < BaseComponent
      with_collection_parameter :profile

      def initialize(profile:)
        @profile = profile
      end

      def ineligible_participant?
        profile.ecf_participant_eligibility&.status == "ineligible"
      end

      def mentor_in_early_rollout?
        return unless profile.mentor?

        profile.ecf_participant_eligibility&.previous_participation_reason?
      end

    private

      attr_reader :profile
    end
  end
end
