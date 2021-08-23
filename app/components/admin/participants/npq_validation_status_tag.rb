# frozen_string_literal: true

module Admin
  module Participants
    class NPQValidationStatusTag < BaseComponent
      def initialize(profile:)
        @profile = profile
      end

      def call
        govuk_tag tag_attributes
      end

    private

      attr_reader :profile

      def tag_attributes
        return { text: "Not ready", colour: "grey" } unless profile.npq?
        return { text: "Complete", colour: "green" } if profile.approved?
        return { text: "Rejected", colour: "red" } if profile.rejected?

        { text: "Pending", colour: "yellow" }
      end
    end
  end
end
