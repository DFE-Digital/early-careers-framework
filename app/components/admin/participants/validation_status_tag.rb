# frozen_string_literal: true

module Admin
  module Participants
    class ValidationStatusTag < BaseComponent
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

        { text: "Pending", colour: "yellow" }
      end
    end
  end
end
