# frozen_string_literal: true

module NewSeeds
  module Scenarios
    class Cohort
      attr_reader :cohort, :schedules, :start_year

      def initialize(start_year = Time.zone.now.year)
        @start_year = start_year
        @schedules = []
      end

      def with_standard_schedule_and_first_milestone
        with_standard_schedule
        @create_first_milestone = true

        self
      end

      def with_standard_schedule
        @create_standard_schedule = true

        self
      end

      def build
        @cohort ||= FactoryBot.create(:seed_cohort, start_year: @start_year)

        add_standard_schedule(@cohort, @create_first_milestone) if @create_standard_schedule

        self
      end

    private

      # noinspection RubyParameterNamingConvention
      def add_standard_schedule(cohort, create_first_milestone)
        schedule = FactoryBot.create(
          :seed_finance_schedule,
          type: "Finance::Schedule::ECF",
          name: "ECF Standard September",
          schedule_identifier: "ecf-standard-september",
          cohort:,
        )

        create_started_milestone(schedule) if create_first_milestone

        @schedules.push(schedule)
      end

      def create_started_milestone(schedule)
        FactoryBot.create(
          :seed_finance_milestone,
          schedule:,
          name: "Output 1 - Participant Start",
          declaration_type: "started",
        )
      end
    end
  end
end
