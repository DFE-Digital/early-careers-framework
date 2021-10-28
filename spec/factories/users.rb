# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    full_name { Faker::Name.name }
    login_token { Faker::Alphanumeric.alpha(number: 10) }
    login_token_valid_until { 1.hour.from_now }

    trait :with_accepted_npq_application do
      transient do
        npq_application_attributes { attributes_for(:npq_application) }
        npq_course { create(:npq_course) }
        npq_lead_provider { create(:npq_lead_provider) }
      end
      after(:create) do |user, evaluator|
        npq_application = NPQ::BuildApplication.call(
          npq_application_params: evaluator.npq_application_attributes,
          npq_course_id: evaluator.npq_course.id,
          npq_lead_provider_id: evaluator.npq_lead_provider.id,
          user_id: user.id,
        )
        npq_application.save!

        NPQ::Accept.call(npq_application: npq_application)
        user.reload
      end
    end

    trait :with_started_npq_declaration do
      with_accepted_npq_application

      transient do
        declaration_type { RecordDeclarations::NPQ::STARTED }
        npq_application { |user| user.npq_applications.first }
      end

      after(:create) do |user, evaluator|
        RecordDeclarations::Started::NPQ.call(
          params: {
            participant_id: user.id,
            course_identifier: evaluator.npq_application.npq_course.identifier,
            declaration_date: (evaluator.npq_application.profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: evaluator.npq_application.npq_lead_provider.cpd_lead_provider,
            declaration_type: evaluator.declaration_type,
          },
        )
        user.reload
      end
    end

    trait :admin do
      admin_profile
    end

    trait :induction_coordinator do
      induction_coordinator_profile

      transient do
        schools { induction_coordinator_profile.schools }
        school_ids {}
      end

      after(:build) do |user, evaluator|
        if evaluator.school_ids.present?
          user.induction_coordinator_profile.school_ids = evaluator.school_ids
        else
          user.induction_coordinator_profile.schools = evaluator.schools
        end
      end
    end

    trait :with_eligible_npq_declaration do
      with_started_npq_declaration

      transient do
        npq_participant_profile { |user| user.npq_applications.first.profile }
      end

      after(:create) do |_user, evaluator|
        RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile
          .call(participant_profile: evaluator.npq_participant_profile)
      end
    end

    trait :with_payable_npq_declarations do
      with_eligible_npq_declaration

      transient do
        start_date { Time.zone.today.beginning_of_month }
        end_date { Time.zone.today.end_of_month + 1.day }
      end

      after(:create) do |_user, evaluator|
        ParticipantDeclaration::NPQ
          .eligible
          .declared_as_between(evaluator.start_date, evaluator.end_date)
          .submitted_between(evaluator.start_date, evaluator.end_date).in_batches do |participant_declarations_group|
          participant_declarations_group.each(&:make_payable!)
        end
      end
    end

    trait :lead_provider do
      lead_provider_profile
    end

    trait :teacher do
      teacher_profile
    end

    trait :early_career_teacher do
      teacher_profile { create(:teacher_profile, early_career_teacher_profile: create(:participant_profile, :ect)) }
    end

    trait :mentor do
      teacher_profile { create(:teacher_profile, mentor_profile: create(:participant_profile, :mentor)) }
    end

    trait :npq do
      teacher_profile { create(:teacher_profile, participant_profiles: [create(:participant_profile, :npq)]) }
    end

    trait :finance do
      finance_profile
    end
  end
end
