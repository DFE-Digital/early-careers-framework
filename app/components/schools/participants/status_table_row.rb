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

        profile.ineligible_status?
      end

      def mentor_in_early_rollout?
        return unless profile.mentor?
        return false unless profile.ecf_participant_eligibility

        profile.previous_participation?
      end

      def participant_is_on_a_cip?
        profile.school_cohort.school_chose_cip?
      end

      def path_ids
        { school_id: profile.school_cohort.school, cohort_id: profile.school_cohort.cohort }
      end

    private

      attr_reader :profile
    end
  end
end
