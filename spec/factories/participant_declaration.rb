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
      participant_profile { create(:participant_profile, :ect, *uplift) }
    end

    factory :mentor_participant_declaration do
      user { create(:user, :mentor) }
      type { "ParticipantDeclaration::ECF" }
      course_identifier { "ecf-mentor" }
      participant_profile { create(:participant_profile, :mentor, *uplift) }
    end

    factory :npq_participant_declaration do
      initialize_with { ParticipantDeclaration::NPQ.new(attributes) }

      user { create(:user, :npq) }
      type { "ParticipantDeclaration::NPQ" }
      course_identifier { NPQCourse.all.map(&:identifier).sample }
      participant_profile { create(:participant_profile, :npq) }
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

    trait :eligible do
      transient do
        state { "eligible" }
      end
    end

    trait :payable do
      state { "payable" }
    end

    trait :voided do
      state { "voided" }
    end

    transient do
      uplift { [] }
    end

    after(:create) do |participant_declaration, _|
      create(:declaration_state,
             participant_declaration.state,
             participant_declaration: participant_declaration)
    end
  end
end
