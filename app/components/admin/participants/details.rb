# frozen_string_literal: true

module Admin
  module Participants
    class Details < BaseComponent
      def initialize(profile:)
        @profile = profile
        @variant = profile.participant_type
      end

    private

      attr_reader :profile
    end
  end
end
