# frozen_string_literal: true

FactoryBot.define do
  factory :schedule, class: "Finance::Schedule" do
    after(:create) do |schedule|
      [
        { name: "Output 1 - Participant Start", start_date: Date.new(2021, 9, 1), milestone_date: Date.new(2021, 11, 30), payment_date: Date.new(2021, 11, 30), declaration_type: "started" },
        { name: "Output 2 – Retention Point 1", start_date: Date.new(2021, 11, 1), milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28), declaration_type: "retained-1" },
        { name: "Output 3 – Retention Point 2", start_date: Date.new(2022, 2, 1), milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31), declaration_type: "retained-2" },
        { name: "Output 4 – Retention Point 3", start_date: Date.new(2022, 5, 1), milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31), declaration_type: "retained-3" },
        { name: "Output 5 – Retention Point 4", start_date: Date.new(2022, 10, 1), milestone_date: Date.new(2023, 1, 31), payment_date: Date.new(2023, 2, 28), declaration_type: "retained-4" },
        { name: "Output 6 – Participant Completion", start_date: Date.new(2023, 2, 1), milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31), declaration_type: "completed" },
      ].each do |hash|
        Finance::Milestone.find_or_create_by!(
          schedule: schedule,
          name: hash[:name],
          start_date: hash[:start_date],
          milestone_date: hash[:milestone_date],
          payment_date: hash[:payment_date],
        ).update!(declaration_type: hash[:declaration_type])
      end
    end

    cohort { Cohort.find_or_create_by!(start_year: 2021) }

    factory :ecf_schedule, class: "Finance::Schedule::ECF", parent: :schedule do
      name { "ECF September standard 2021" }
      schedule_identifier { "ecf-standard-september" }

      factory :ecf_schedule_january do
        name { "ECF January standard 2021" }
        schedule_identifier { "ecf-standard-january" }
      end
    end

    factory :npq_specialist_schedule, class: "Finance::Schedule::NPQSpecialist", parent: :schedule do
      name { "NPQ Specialist November 2021" }
      schedule_identifier { "npq-specialist-november-2021" }
    end

    factory :npq_leadership_schedule, class: "Finance::Schedule::NPQLeadership", parent: :schedule do
      name { "NPQ Leadership November 2021" }
      schedule_identifier { "npq-leadership-november-2021" }
    end
  end
end
