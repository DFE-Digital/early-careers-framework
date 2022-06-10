# frozen_string_literal: true

FactoryBot.define do
  factory :npq_application do
    transient do
      user { create(:user) }
    end

    npq_course
    npq_lead_provider                     { create(:cpd_lead_provider, :with_npq_lead_provider).npq_lead_provider }
    cohort                                { Cohort.current || create(:cohort, :current) }
    headteacher_status                    { NPQApplication.headteacher_statuses.keys.sample }
    funding_choice                        { NPQApplication.funding_choices.keys.sample }
    works_in_school                       { true }
    school_urn                            { rand(100_000..999_999).to_s }
    school_ukprn                          { rand(10_000_000..99_999_999).to_s }
    date_of_birth                         { rand(25..50).years.ago + rand(0..365).days }
    teacher_reference_number              { user.teacher_profile&.trn || rand(1_000_000..9_999_999).to_s }
    teacher_reference_number_verified     { true }
    nino                                  { SecureRandom.hex }
    active_alert                          { false }
    eligible_for_funding                  { false }
    funding_eligiblity_status_code        { :ineligible_establishment_type }
    targeted_delivery_funding_eligibility { true }
    teacher_catchment { "england" }
    teacher_catchment_country { nil }

    initialize_with do
      NPQ::BuildApplication.call(
        npq_application_params: {
          active_alert:,
          date_of_birth:,
          eligible_for_funding:,
          funding_choice:,
          headteacher_status:,
          nino:,
          works_in_school:,
          school_urn:,
          school_ukprn:,
          teacher_reference_number:,
          teacher_reference_number_verified:,
          teacher_catchment:,
          teacher_catchment_country:,
        },
        npq_course_id: npq_course.id,
        npq_lead_provider_id: npq_lead_provider.id,
        user_id: user.id,
      ).tap(&:save!)
    end

    trait :funded do
      eligible_for_funding { true }
      funding_eligiblity_status_code { :funded }
    end

    trait :eligible_for_funding do
      funded
    end

    trait :accepted do
      after :create do |npq_application|
        NPQ::Accept.call(npq_application:)
        npq_application.reload
      end
    end

    trait :eligible_for_funding do
      eligible_for_funding { true }
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
               participant_profile: npq_application.profile,
               course_identifier: npq_application.npq_course.identifier)
      end
    end
  end
end
