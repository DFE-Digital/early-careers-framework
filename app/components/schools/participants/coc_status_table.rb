# frozen_string_literal: true

module Schools
  module Participants
    class CocStatusTable < BaseComponent
      def initialize(induction_records:)
        @induction_records = induction_records
      end

      def ineligible_participants?
        ParticipantProfile::ECF.ineligible_status.where(id: induction_records.map(&:participant_profile_id)).any?
      end

      def transferring_out_participants?
        induction_records.any?(&:transferring_out?)
      end

      def transferring_in_participants?
        induction_records.any?(&:transferring_in?)
      end

      def transferred_participants?
        induction_records.any?(&:transferred?)
      end

      # this doesn't really work in the new data model as there could be multiple
      # programmes running in the cohort
      def school_chose_cip?
        induction_records.first.school_cohort.core_induction_programme?
      end

      def date_column_heading
        if transferring_out_participants?
          "Leaving"
        elsif transferring_in_participants?
          "Joining"
        elsif transferred_participants?
          "Transferred"
        else
          "Induction start"
        end
      end

      attr_reader :induction_records
    end
  end
end
