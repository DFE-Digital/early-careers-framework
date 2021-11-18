# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    full_name { Faker::Name.name }
    login_token { Faker::Alphanumeric.alpha(number: 10) }
    login_token_valid_until { 1.hour.from_now }

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
      teacher_profile { create(:teacher_profile, early_career_teacher_profile: create(:ect_participant_profile)) }
    end

    trait :mentor do
      teacher_profile { create(:teacher_profile, mentor_profile: create(:mentor_participant_profile)) }
    end

    trait :npq do
      teacher_profile { create(:teacher_profile, participant_profiles: [create(:npq_participant_profile)]) }
    end

    trait :finance do
      finance_profile
    end
  end
end
