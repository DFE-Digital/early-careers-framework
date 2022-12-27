# frozen_string_literal: true

FactoryBot.define do
  # 🚨 Danger, participant declarations link to both a User and a
  # ParticipantProfile. This means we end up with two users despite always
  # being able to infer a user via the participant profile. If possible hard
  # code these values when calling this factory
  factory(:seed_participant_declaration, class: "ParticipantDeclaration") do
    declaration_date { Faker::Date.between(from: 2.years.ago, to: 1.day.ago) }
    course_identifier { "ecf-induction" }

    trait(:with_cpd_lead_provider) { association(:cpd_lead_provider, factory: :seed_cpd_lead_provider) }
    trait(:with_user) { association(:user, factory: :seed_user) }
    trait(:with_participant_profile) do
      association(:participant_profile, factory: %i[seed_ecf_participant_profile valid])
    end

    trait(:valid) do
      with_user
      with_cpd_lead_provider
      with_participant_profile
    end

    declaration_type { "started" }
    trait(:started) { declaration_type { "started" } }
    trait(:completed) { declaration_type { "completed" } }
    trait(:retained_1) { declaration_type { "retained-1" } }
    trait(:retained_2) { declaration_type { "retained-2" } }
    trait(:retained_3) { declaration_type { "retained-3" } }
    trait(:retained_4) { declaration_type { "retained-4" } }
    trait(:retained) { declaration_type { %w[retained-1 retained-2 retained-3 retained-4].sample } }

    sparsity_uplift { false }
    pupil_premium_uplift { false }
    trait(:with_sparsity_uplift) { sparsity_uplift { true } }
    trait(:with_pupil_premium_uplift) { pupil_premium_uplift { true } }

    after(:build) do |pd|
      if pd.user.present?
        Rails.logger.debug("seeded participant declaration for user #{pd.user.full_name}")
      else
        Rails.logger.debug("seeded incomplete participant declaration")
      end
    end
  end
end
