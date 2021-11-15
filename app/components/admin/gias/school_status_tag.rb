# frozen_string_literal: true

module Admin
  module Gias
    class SchoolStatusTag < BaseComponent
      def initialize(school:)
        @school = school
      end

      def call
        govuk_tag(**tag_attributes)
      end

    private

      attr_reader :school

      def tag_attributes
        return { text: "Closed", colour: "grey" } if school.closed_status?
        return { text: "Proposed to open", colour: "grey" } if school.proposed_to_open_status?
        return { text: "Proposed to close", colour: "orange" } if school.proposed_to_close_status?

        { text: "Open", colour: "green" }
      end
    end
  end
end
