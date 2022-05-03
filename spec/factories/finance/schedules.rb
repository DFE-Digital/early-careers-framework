# frozen_string_literal: true

FactoryBot.define do
  factory :schedule, class: "Finance::Schedule" do
    trait(:with_ecf_milestones) do
      after(:create) do |_schedule|
        Importers::SeedSchedule.new(
          path_to_csv: Rails.root.join("db/seeds/schedules/ecf_standard.csv"),
          klass: Finance::Schedule::ECF,
        ).call
      end
    end

    trait(:with_npq_milestones) do
      after(:create) do |_schedule|
        Importers::SeedSchedule.new(
          path_to_csv: Rails.root.join("db/seeds/schedules/npq_specialist.csv"),
          klass: Finance::Schedule::NPQSpecialist,
        ).call

        Importers::SeedSchedule.new(
          path_to_csv: Rails.root.join("db/seeds/schedules/npq_leadership.csv"),
          klass: Finance::Schedule::NPQLeadership,
        ).call
      end
    end

    cohort { Cohort.current || create(:cohort, :current) }
    sequence(:schedule_identifier) { |n| "schedule-identifier-#{n}" }

    factory :ecf_schedule, class: "Finance::Schedule::ECF", parent: :schedule do
      name { "ECF September standard 2021" }
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
  end
end
