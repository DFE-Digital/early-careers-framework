# frozen_string_literal: true

module Admin
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :profile

      def initialize(profile:)
        @profile = profile
      end

      def school_urn
        school&.urn || profile.school_urn
      end

    private

      attr_reader :profile

      def induction_record
        return unless @profile.ect? || @profile.mentor?

        @induction_record ||= @profile.latest_current_induction_record
      end

      def school
        induction_record&.school || profile.school
      end
    end
  end
end
