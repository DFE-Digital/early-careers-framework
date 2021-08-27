# frozen_string_literal: true

module Schools
  module Participants
    class RemoveFromCohortComponent < BaseComponent
      def initialize(profile:)
        @profile = profile
      end

    private

      attr_reader :profile

      def manual_removal_possible?
        !profile.completed_validation_wizard?
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
    end
  end
end
