# frozen_string_literal: true

module Schools
  module Participants
    class StatusTable < BaseComponent
      def initialize(participant_profiles:)
        @participant_profiles = participant_profiles
      end

      def ineligible_participants?
        participant_profiles.all? { |pp| pp.ecf_participant_eligibility&.status == "ineligible" }
      end

      attr_reader :participant_profiles
    end
  end
end
