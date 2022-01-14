# frozen_string_literal: true

module Schools
  module Participants
    class RemoveFromCohortComponent < BaseComponent
      def initialize(profile:, current_user:)
        @profile = profile
        @current_user = current_user
      end

    private

      attr_reader :current_user, :profile

      def manual_removal_possible?
        ParticipantProfile::ECFPolicy.new(current_user, profile).withdraw_record?
      end

      def fip?
        profile.school_cohort.full_induction_programme?
      end

      def cip?
        profile.school_cohort.core_induction_programme?
      end

      def name
        profile.user.full_name
      end

      def lead_provider
        profile.school_cohort.lead_provider
      end
    end
  end
end
