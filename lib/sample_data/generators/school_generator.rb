# frozen_string_literal: true

module SampleData
  module Generators
    class SchoolGenerator
      extend SampleData::Generators::Support::GeneratorClassUtil

      attr_reader :overrides, :school, :mentors

      def initialize(**overrides)
        @overrides = overrides
        @mentors = []
      end

      def generate(&block)
        Rails.logger.debug("generating school")

        @school = School.create!(**attributes)

        if block_given?
          Rails.logger.debug("generating school: block provided")
          block.call(self)
        end

        Rails.logger.debug("generating school: school #{@school.id} created")

        self
      end

      def with_cohort(start_year:, **kwargs, &block)
        Rails.logger.debug("generating school: generating school cohort")

        SampleData::Generators::SchoolCohortGenerator.generate(start_year:, school:, **kwargs, &block)
      end

      def with_mentor(**kwargs, &block)
        Rails.logger.debug("generating school: generating mentor")

        @mentors << SampleData::Generators::MentorGenerator.generate(school:, **kwargs, &block)
      end

    private

      def attributes
        FactoryBot.attributes_for(:school).merge(overrides)
      end
    end
  end
end
