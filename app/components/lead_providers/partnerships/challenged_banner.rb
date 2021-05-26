# frozen_string_literal: true

module LeadProviders
  module Partnerships
    class ChallengedBanner < BaseComponent
      def initialize(partnership:)
        @partnership = partnership
      end

      def render?
        partnership.challenged?
      end

    private

      attr_reader :partnership

      def challenge_reason
        t(partnership.challenge_reason, scope: "partnerships.challenge_reasons")
      end
    end
  end
end
