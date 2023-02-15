# frozen_string_literal: true

module Schools
  module Participants
    class StatusTable < BaseComponent
      def initialize(participant_profiles:, school_cohort:)
        @participant_profiles = participant_profiles
        @school_cohort = school_cohort
      end

      def ineligible_participants?
        participant_profiles.all?(&:ineligible?)
      end

      attr_reader :participant_profiles, :school_cohort
    end
  end
end
