# frozen_string_literal: true

module SampleData
  module Generators
    class TeacherProfileGenerator
      extend SampleData::Generators::Support::GeneratorClassUtil

      attr_reader :overrides, :teacher_profile

      def initialize(**overrides)
        @overrides = overrides
      end

      def generate
        Rails.logger.debug("generating teacher profile")

        @teacher_profile = TeacherProfile.create!(**attributes)

        self
      end

    private

      def attributes
        FactoryBot.attributes_for(:teacher_profile).merge(overrides)
      end
    end
  end
end
