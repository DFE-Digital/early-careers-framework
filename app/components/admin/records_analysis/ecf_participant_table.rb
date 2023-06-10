# frozen_string_literal: true

module Admin
  module RecordsAnalysis
    class ECFParticipantTable < BaseComponent
      include Pagy::Backend
      def initialize(participant_profiles:, page:)
        @pagy, @participant_profiles = pagy(participant_profiles, page:, items: 10)
      end

    private

      attr_reader :participant_profiles
    end
  end
end
