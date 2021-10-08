# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    user
    cpd_lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "started" }
    state { "submitted" }

    factory :ect_participant_declaration do
      user { create(:user, :early_career_teacher) }
      type { "ParticipantDeclaration::ECF" }
      course_identifier { "ecf-induction" }
      profile_type { :ect }
      with_profile_type
    end

    factory :mentor_participant_declaration do
      user { create(:user, :mentor) }
      type { "ParticipantDeclaration::ECF" }
      course_identifier { "ecf-mentor" }
      profile_type { :mentor }
      with_profile_type
    end

    factory :npq_participant_declaration do
      initialize_with { ParticipantDeclaration::NPQ.new(attributes) }

      user { create(:user, :npq) }
      type { "ParticipantDeclaration::NPQ" }
      profile_type { :npq }
      course_identifier { NPQCourse.all.map(&:identifier).sample }
      with_profile_type
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

    trait :submitted do
      state { "submitted" }
    end

    trait :eligible do
      state { "eligible" }
    end

    trait :payable do
      state { "payable" }
    end

    trait :voided do
      state { "voided" }
    end

    transient do
      uplift { [] }
      profile_type { :ect }
    end

    trait :with_profile_type do
      after(:create) do |participant_declaration, evaluator|
        create(:profile_declaration,
               participant_declaration: participant_declaration,
               participant_profile: create(
                 :participant_profile,
                 evaluator.profile_type,
                 *evaluator.uplift,
               ))
      end
    end

    after(:create) do |participant_declaration, _|
      create(:declaration_state,
             participant_declaration.state,
             participant_declaration: participant_declaration)
    end
  end
end
