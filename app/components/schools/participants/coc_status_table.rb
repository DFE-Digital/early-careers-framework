# frozen_string_literal: true

module Schools
  module Participants
    class CocStatusTable < BaseComponent
      def initialize(induction_records:)
        @induction_records = induction_records
      end

      def ineligible_participants?
        induction_records.any?(&:participant_ineligible_but_not_duplicated_or_previously_participated?)
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

      # add the below back in once we do the transferring out journey
      # transferring out currently list in the ECT or Mentor tabs
      # if transferring_out_participants?
      #   "Leaving"
      def date_column_heading
        if transferring_in_participants?
          "Joining"
        elsif transferring_out_participants?
          "Leaving"
        elsif transferred_participants?
          "Transferred"
        else
          ""
        end
      end

      attr_reader :induction_records
    end
  end
end
