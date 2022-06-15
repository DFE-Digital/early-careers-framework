# frozen_string_literal: true

module Schools
  module Participants
    class StatusTableRow < BaseComponent
      with_collection_parameter :profile

      def initialize(profile:)
        @profile = profile
      end

      def ineligible_participant?
        return false unless profile.ecf_participant_eligibility

        profile.ecf_participant_eligibility.ineligible_status?
      end

      def mentor_in_early_rollout?
        return unless profile.mentor?
        return false unless profile.ecf_participant_eligibility

        profile.ecf_participant_eligibility.previous_participation_reason?
      end

      def participant_is_on_a_cip?
        profile.school_cohort.school_chose_cip?
      end

      def date_column_value; end

    private

      attr_reader :profile
    end
  end
end
