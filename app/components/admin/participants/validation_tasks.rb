# frozen_string_literal: true

module Admin
  module Participants
    class ValidationTasks < BaseComponent
      def initialize(profile:)
        @profile = profile
      end

    private

      attr_reader :profile

      def validation_steps
        profile.class.validation_steps
      end

      def tag_attributes(step)
        decision = profile.validation_decision(step)
        return { colour: "yellow", text: "Pending" } if decision.new_record?
      end
    end
  end
end
