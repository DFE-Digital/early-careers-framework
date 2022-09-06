# frozen_string_literal: true

FactoryBot.define do
  factory :schedule, class: "Finance::Schedule" do
    trait(:with_ecf_milestones) do
      after(:create) do |schedule|
        start_year = schedule.cohort.start_year
        [
          { name: "Output 1 - Participant Start", start_date: Date.new(start_year, 9, 1), milestone_date: Date.new(2021, 11, 30), payment_date: Date.new(2021, 11, 30), declaration_type: "started" },
          { name: "Output 2 - Retention Point 1", start_date: Date.new(start_year, 11, 1), milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28), declaration_type: "retained-1" },
          { name: "Output 3 - Retention Point 2", start_date: Date.new(start_year, 2, 1), milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31), declaration_type: "retained-2" },
          { name: "Output 4 - Retention Point 3", start_date: Date.new(start_year, 5, 1), milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31), declaration_type: "retained-3" },
          { name: "Output 5 - Retention Point 4", start_date: Date.new(start_year, 10, 1), milestone_date: Date.new(2023, 1, 31), payment_date: Date.new(2023, 2, 28), declaration_type: "retained-4" },
          { name: "Output 6 - Participant Completion", start_date: Date.new(start_year + 1, 2, 1), milestone_date: Date.new(start_year + 1, 4, 30), payment_date: Date.new(start_year + 1, 5, 31), declaration_type: "completed" },
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

    trait(:with_npq_milestones) do
      after(:create) do |schedule|
        [
          { name: "Output 1 - Participant Start", start_date: Date.new(2021, 9, 1), payment_date: Date.new(2021, 11, 30), declaration_type: "started" },
          { name: "Output 2 - Retention Point 1", start_date: Date.new(2021, 11, 1), payment_date: Date.new(2022, 2, 28), declaration_type: "retained-1" },
          { name: "Output 3 - Retention Point 2", start_date: Date.new(2022, 2, 1), payment_date: Date.new(2022, 5, 31), declaration_type: "retained-2" },
          { name: "Output 4 - Participant Completion", start_date: Date.new(2023, 2, 1), payment_date: Date.new(2023, 5, 31), declaration_type: "completed" },
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
        name { "ECF January standard 2021" }
        schedule_identifier { "ecf-standard-january" }
      end
    end

    factory :ecf_mentor_schedule, class: "Finance::Schedule::Mentor", parent: :schedule do
      name { "Schedule for mentors only" }
      schedule_identifier { "ecf-replacement-april" }

      with_ecf_milestones
    end

    factory :npq_specialist_schedule, class: "Finance::Schedule::NPQSpecialist", parent: :schedule do
      name { "NPQ Specialist Spring 2021" }
      schedule_identifier { "npq-specialist-spring" }

      with_npq_milestones
    end

    factory :npq_leadership_schedule, class: "Finance::Schedule::NPQLeadership", parent: :schedule do
      name { "NPQ Leadership Spring 2021" }
      schedule_identifier { "npq-leadership-spring" }

      with_npq_milestones
    end

    factory :npq_aso_schedule, class: "Finance::Schedule::NPQSupport", parent: :schedule do
      name { "NPQ Additional Support Offer December 2021" }
      schedule_identifier { "npq-aso-december" }

      with_npq_milestones
    end

    factory :npq_ehco_schedule, class: "Finance::Schedule::NPQEhco", parent: :schedule do
      name { "NPQ EHCO December 2021" }
      schedule_identifier { "npq-ehco-december" }

      with_npq_milestones
    end
  end
end
