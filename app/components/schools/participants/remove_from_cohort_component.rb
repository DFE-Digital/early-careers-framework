# frozen_string_literal: true

module Schools
  module Participants
    class RemoveFromCohortComponent < BaseComponent
      def initialize(induction_record:, current_user:)
        @induction_record = induction_record
        @current_user = current_user
      end

    private

      attr_reader :current_user, :induction_record

      def manual_removal_possible?
        ParticipantProfile::ECFPolicy.new(current_user, induction_record.participant_profile).withdraw_record?
      end

      def fip?
        induction_record.enrolled_in_fip?
      end

      def cip?
        induction_record.enrolled_in_cip?
      end

      def name
        induction_record.user.full_name
      end

      def lead_provider
        induction_record.lead_provider
      end
    end
  end
end
