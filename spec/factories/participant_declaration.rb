# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    user
    cpd_lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "started" }

    factory :ect_participant_declaration do
      type { "ParticipantDeclaration::ECF" }
      course_identifier { "ecf-induction" }
      profile_type { :early_career_teacher_profile }
      with_profile_type
    end

    factory :mentor_participant_declaration do
      type { "ParticipantDeclaration::ECF" }
      course_identifier { "ecf-mentor" }
      profile_type { :mentor_profile }
      with_profile_type
    end

    factory :npq_participant_declaration do
      course_identifier { NPQCourse.all.map(&:identifier).sample }
    end

    trait :sparsity_uplift do
      uplift { :sparsity_uplift }
    end

    trait :pupil_premium_uplift do
      uplift { :pupil_premium_uplift }
    end

    trait :uplift_flags do
      uplift { :uplift_flags }
    end

    transient do
      uplift { false }
      profile_type { :early_career_teacher_profile }
    end

    trait :with_profile_type do
      after(:create) do |participant_declaration, evaluator|
        create(:profile_declaration,
               participant_declaration: participant_declaration,
               participant_profile: create(
                 evaluator.profile_type,
                 evaluator.uplift,
               ))
      end
    end
  end
end
