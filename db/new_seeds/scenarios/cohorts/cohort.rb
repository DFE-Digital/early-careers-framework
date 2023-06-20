# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Cohorts
      class Cohort
        include RSpec::Mocks::Syntax

        attr_reader :cohort, :schedules, :start_year, :is_current

        def initialize(start_year: Time.zone.now.year.to_i)
          @start_year = start_year
          @schedules = []
        end

        def build
          @cohort = FactoryBot.create(:seed_cohort, start_year: @start_year)

          self
        end

        def with_schedule(**schedule_args)
          add_schedule(**schedule_args)

          self
        end

        def with_milestone(**milestone_args)
          add_milestone(**milestone_args)

          self
        end

        def with_schedule_and_milestone
          add_schedule
          add_milestone

          self
        end

        def add_schedule(type: "Finance::Schedule::ECF", name: "ECF Standard September", schedule_identifier: "ecf-standard-september")
          schedule = FactoryBot.create(:seed_finance_schedule, type:, name:, schedule_identifier:, cohort:)
          @schedules.push(schedule)
          schedule
        end

        def add_milestone(schedule: @schedules.first, declaration_type: "started", name: "Output 1 - Participant Start")
          add_schedule if schedule.nil?

          FactoryBot.create :seed_finance_milestone, schedule:, name:, declaration_type:
        end
      end
    end
  end
end
