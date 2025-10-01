# frozen_string_literal: true

FactoryBot.define do
  factory :schedule, class: "Finance::Schedule" do
    trait(:with_ecf_milestones) do
      after(:create) do |schedule|
        start_year = schedule.cohort.start_year
        [
          {
            name: "Output 1 - Participant Start",
            start_date: Date.new(start_year, 9, 1),
            milestone_date: Date.new(start_year, 11, 30),
            payment_date: Date.new(start_year, 11, 30),
            declaration_type: "started",
          },
          {
            name: "Output 2 - Retention Point 1",
            start_date: Date.new(start_year, 11, 1),
            milestone_date: Date.new(start_year + 1, 1, 31),
            payment_date: Date.new(start_year + 1, 2, 28),
            declaration_type: "retained-1",
          },
          {
            name: "Output 3 - Retention Point 2",
            start_date: Date.new(start_year + 1, 2, 1),
            milestone_date: Date.new(start_year + 1, 4, 30),
            payment_date: Date.new(start_year + 1, 5, 31),
            declaration_type: "retained-2",
          },
          {
            name: "Output 4 - Retention Point 3",
            start_date: Date.new(start_year + 1, 5, 1),
            milestone_date: Date.new(start_year + 1, 9, 30),
            payment_date: Date.new(start_year + 1, 10, 31),
            declaration_type: "retained-3",
          },
          {
            name: "Output 5 - Retention Point 4",
            start_date: Date.new(start_year + 1, 10, 1),
            milestone_date: Date.new(start_year + 2, 1, 31),
            payment_date: Date.new(start_year + 2, 2, 28),
            declaration_type: "retained-4",
          },
          {
            name: "Output 6 - Participant Completion",
            start_date: Date.new(start_year + 2, 2, 1),
            milestone_date: Date.new(start_year + 2, 4, 30),
            payment_date: Date.new(start_year + 2, 5, 31),
            declaration_type: "completed",
          },
        ].each do |hash|
          Finance::Milestone.find_or_create_by!(
            schedule:,
            name: hash[:name],
            start_date: hash[:start_date],
            milestone_date: hash[:milestone_date],
            payment_date: hash[:payment_date],
          ).update!(declaration_type: hash[:declaration_type])
        end
      end
    end

    trait(:with_ecf_extended_milestones) do
      after(:create) do |schedule|
        start_year = schedule.cohort.start_year
        [
          {
            name: "Output 7 - Extended Point 1",
            start_date: Date.new(start_year, 9, 1),
            payment_date: Date.new(start_year, 9, 1),
            declaration_type: "extended-1",
          },
          {
            name: "Output 8 - Extended Point 2",
            start_date: Date.new(start_year, 9, 1),
            payment_date: Date.new(start_year, 9, 1),
            declaration_type: "extended-2",
          },
          {
            name: "Output 9 - Extended Point 3",
            start_date: Date.new(start_year, 9, 1),
            payment_date: Date.new(start_year, 9, 1),
            declaration_type: "extended-3",
          },
        ].each do |hash|
          Finance::Milestone.find_or_create_by!(
            schedule:,
            name: hash[:name],
            start_date: hash[:start_date],
            payment_date: hash[:payment_date],
          ).update!(declaration_type: hash[:declaration_type])
        end
      end
    end

    cohort { Cohort.current || create(:cohort, :current) }
    sequence(:schedule_identifier) { |n| "schedule-identifier-#{n}" }

    trait :soft do
      schedule_identifier { "soft-schedule" }
      name { "soft-schedule" }

      after(:create) do |schedule|
        create(:milestone, :soft_milestone, :started, schedule:)
      end
    end

    factory :ecf_schedule, class: "Finance::Schedule::ECF", parent: :schedule do
      name                { |schedule| "ECF September standard #{schedule.cohort.start_year}" }
      schedule_identifier { "ecf-standard-september" }

      with_ecf_milestones

      factory :ecf_schedule_january do
        name { "ECF January standard" }
        schedule_identifier { "ecf-standard-january" }
      end
    end

    factory :ecf_extended_schedule, class: "Finance::Schedule::ECF", parent: :schedule do
      name                { |schedule| "ECF September extended #{schedule.cohort.start_year}" }
      schedule_identifier { "ecf-extended-september" }

      with_ecf_milestones
      with_ecf_extended_milestones
    end

    factory :ecf_mentor_schedule, class: "Finance::Schedule::Mentor", parent: :schedule do
      name { "Schedule for mentors only" }
      schedule_identifier { "ecf-replacement-april" }

      with_ecf_milestones
    end
  end
end
