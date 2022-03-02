# frozen_string_literal: true

module Schools
  module Participants
    class StatusTable < BaseComponent
      def initialize(participant_profiles:, school_cohort:)
        @participant_profiles = participant_profiles
        @school_cohort = school_cohort
      end

      def ineligible_participants?
        participant_profiles.all? { |pp| pp.ecf_participant_eligibility&.ineligible_status? }
      end

      def transferring_out_participants?
        school_cohort.transferring_out_induction_records.where(participant_profile: participant_profiles).any?
      end

      def transferring_in_participants?
        school_cohort.transferring_in_induction_records.where(participant_profile: participant_profiles).any?
      end

      def date_column_heading
        if FeatureFlag.active?(:change_of_circumstances)
          if transferring_out_participants?
            "Leaving"
          elsif transferring_in_participants?
            "Joining"
          else
            "Induction start"
          end
        else
          "Induction start"
        end
      end

      attr_reader :participant_profiles, :school_cohort
    end
  end
end
