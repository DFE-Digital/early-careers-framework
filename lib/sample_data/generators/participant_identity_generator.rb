# frozen_string_literal: true

module SampleData
  module Generators
    class ParticipantIdentityGenerator
      extend SampleData::Generators::Support::GeneratorClassUtil

      attr_reader :overrides, :participant_identity

      def initialize(**overrides)
        @overrides = overrides
      end

      def generate
        Rails.logger.debug("generating participant identity")

        @participant_identity = ParticipantIdentity.create!(**attributes)

        self
      end

    private

      def attributes
        FactoryBot.attributes_for(:participant_identity).merge(overrides)
      end
    end
  end
end
