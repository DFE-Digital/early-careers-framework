# frozen_string_literal: true

FactoryBot.define do
  factory :npq_application do
    participant_identity
    npq_course
    npq_lead_provider
    cohort { Cohort.current || create(:cohort, :current) }

    headteacher_status { NPQApplication.headteacher_statuses.keys.sample }
    funding_choice { NPQApplication.funding_choices.keys.sample }
    works_in_school { true }
    school_urn { rand(100_000..999_999).to_s }
    school_ukprn { rand(10_000_000..99_999_999).to_s }
    date_of_birth { rand(25..50).years.ago + rand(0..365).days }
    teacher_reference_number { rand(1_000_000..9_999_999).to_s }

    eligible_for_funding { false }
    funding_eligiblity_status_code { :ineligible_establishment_type }

    trait :funded do
      eligible_for_funding { true }
      funding_eligiblity_status_code { :funded }
    end

    trait :accepted do
      after :create do |npq_application|
        NPQ::Accept.call(npq_application:)
      end
    end

    trait :rejected do
      lead_provider_approval_status { "rejected" }
    end

    trait :not_in_school do
      works_in_school { false }
      school_urn { nil }
      school_ukprn { nil }
      employer_name { "Some Company Ltd" }
      employment_role { "Director" }
    end

    trait :in_private_childcare_provider do
      works_in_school { false }
      school_urn { nil }
      school_ukprn { nil }
      works_in_nursery { true }
      works_in_childcare { true }
      kind_of_nursery { "private_nursery" }
      private_childcare_provider_urn { "EY#{rand(100_000..999_999)}" }
    end

    trait :with_started_declaration do
      after :create do |npq_application|
        create(:npq_participant_declaration,
               declaration_type: "started",
               user: npq_application.user,
               participant_profile: npq_application.user.participant_profiles.first,
               course_identifier: npq_application.npq_course.identifier)
      end
    end
  end
end
