# frozen_string_literal: true

module SampleData
  module Generators
    class SchoolCohortGenerator
      attr_reader :overrides, :cohort, :school

      def initialize(start_year:, school:, **overrides)
        @cohort = Cohort.find_by!(start_year:)
        @school = school
        @overrides = overrides
      end

      def self.generate(**kwargs, &block)
        new(**kwargs).generate(&block)
      end

      def generate(&block)
        Rails.logger.debug("generating school cohort")

        @school = SchoolCohort.create!(**attributes)

        if block_given?
          Rails.logger.debug("generating school cohort: block provided")

          block.call(self)
        end

        self
      end

    private

      def attributes
        FactoryBot.attributes_for(:school_cohort).merge({ school:, cohort:, **overrides })
      end
    end
  end
end
