# frozen_string_literal: true

module Schools
  module Participants
    class CocStatusTableRow < BaseComponent
      with_collection_parameter :induction_record

      delegate :transferring_out?, :transferring_in?, :transferred?, to: :induction_record

      def initialize(induction_record:)
        @induction_record = induction_record
      end

      def ineligible_participant?
        induction_record.participant_ineligible_but_not_duplicated_or_previously_participated?
      end

      def mentor_in_early_rollout?
        induction_record.mentor? && induction_record.participant_previous_participation?
      end

      def participant_is_on_a_cip?
        induction_record.enrolled_in_cip?
      end

      # Add transferring_out? || transferred? back in once transfer out journey has been done.
      def date_column_value
        if transferred? || transferring_out?
          induction_record.end_date.to_date.to_s(:govuk)
        elsif transferring_in?
          induction_record.start_date.to_date.to_s(:govuk)
        else
          ""
        end
      end

      def path_ids
        if FeatureFlag.active? :cohortless_dashboard
          { school_id: induction_record.school }
        else
          { school_id: induction_record.school, cohort_id: induction_record.cohort_start_year }
        end
      end

    private

      attr_reader :induction_record
    end
  end
end
