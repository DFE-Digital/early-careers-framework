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
        ParticipantProfile::ECF.ineligible_status.exists?(id: induction_record.participant_profile_id)
      end

      def mentor_in_early_rollout?
        ParticipantProfile::Mentor
          .joins(:ecf_participant_eligibility)
          .where(ecf_participant_eligibility: { reason: :previous_participation })
          .exists?(id: induction_record.participant_profile_id)
      end

      def participant_is_on_a_cip?
        induction_record.induction_programme.core_induction_programme?
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
        { school_id: induction_record.school, cohort_id: induction_record.cohort.start_year }
      end

    private

      attr_reader :induction_record
    end
  end
end
