# frozen_string_literal: true

module Admin
  module Participants
    module FindInductionRecords
      extend ActiveSupport::Concern

      def relevant_induction_record
        Induction::FindBy.call(participant_profile: @participant_profile)
      end

      def historical_induction_records
        induction_records[1..]
      end

      def all_induction_records
        induction_records
      end

    private

      def induction_records
        @induction_records ||= @participant_profile
          .induction_records
          .eager_load(
            :appropriate_body,
            :preferred_identity,
            :schedule,
            induction_programme: {
              partnership: :lead_provider,
              school_cohort: %i[cohort school],
            },
            mentor_profile: :user,
          )
          .order(start_date: :desc, created_at: :desc)
      end
    end
  end
end
