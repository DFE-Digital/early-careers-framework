# frozen_string_literal: true

FactoryBot.define do
  factory :npq_application do
    transient do
      user { create(:user) }
    end
    npq_course                            { create(:npq_course) }
    npq_lead_provider                     { create(:cpd_lead_provider, :with_npq_lead_provider).npq_lead_provider }
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
    targeted_delivery_funding_eligibility { false }
    teacher_catchment                     { "england" }
    teacher_catchment_country             { nil }
    itt_provider                          { "University of Southampton" }
    lead_mentor                           { true }

    association :cohort, factory: %i[cohort current]

    before(:create) do |npq_application, evaluator|
      npq_application.participant_identity = Identity::Create.call(user: evaluator.user, origin: :npq)
    end

    trait :funded do
      eligible_for_funding { true }
      funding_eligiblity_status_code { :funded }
    end

    trait :funded_place do
      funded_place { true }
    end

    trait :no_funded_place do
      funded_place { false }
    end

    trait :eligible_for_funding do
      funded
    end

    trait :edge_case do
      works_in_school { false }
      works_in_childcare { false }
      funding_eligiblity_status_code { "re_register" }
    end

    trait :targeted_delivery_funding_eligibility do
      targeted_delivery_funding_eligibility { true }
    end

    trait :accepted do
      after(:create) do |npq_application, evaluator|
        npq_application.update!(lead_provider_approval_status: "accepted")
        user = evaluator.user
        teacher_profile = user.teacher_profile || user.build_teacher_profile
        teacher_profile.update!(trn: npq_application.teacher_reference_number)
        ParticipantProfile::NPQ.create!(
          id: npq_application.id,
          schedule: NPQCourse.schedule_for(npq_course: npq_application.npq_course, cohort: npq_application.cohort),
          npq_course: npq_application.npq_course,
          teacher_profile:,
          school_urn: npq_application.school_urn,
          school_ukprn: npq_application.school_ukprn,
          participant_identity: npq_application.participant_identity,
        ).tap do |pp|
          ParticipantProfileState.find_or_create_by(participant_profile: pp)
        end
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
  end
end
