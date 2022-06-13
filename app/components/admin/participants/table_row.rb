# frozen_string_literal: true

module Admin
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :profile

      def initialize(profile:)
        @profile = profile
        @induction_record = get_induction_record
      end

      def school_urn
        school&.urn || profile.school_urn
      end

    private

      attr_reader :profile, :induction_record

      def get_induction_record
        return unless @profile.ect? || @profile.mentor?

        @profile.current_induction_record || @profile.induction_records.latest
      end

      def school
        induction_record&.school || profile.school
      end
    end
  end
end
