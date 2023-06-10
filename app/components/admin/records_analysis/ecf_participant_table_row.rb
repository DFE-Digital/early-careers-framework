# frozen_string_literal: true

module Admin
  module RecordsAnalysis
    class ECFParticipantTableRow < BaseComponent
      include AdminHelper

      with_collection_parameter :participant_profile

      def initialize(participant_profile:)
        @participant_profile = participant_profile
        @user = participant_profile.user
        @induction_programme = find_induction_programme
      end

    private

      attr_reader :participant_profile, :user, :induction_programme

      def find_induction_programme
        participant_profile.current_induction_records.first.induction_programme
      end
    end
  end
end
