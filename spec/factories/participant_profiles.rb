# frozen_string_literal: true

FactoryBot.define do
  factory :participant_profile do
    transient do
      cohort         { Cohort.current || create(:cohort, :current) }
      profile_traits { [] }
    end

    trait(:ecf) do
      profile_duplicity { :single }
      school_cohort { association :school_cohort, cohort: }
      teacher_profile { association :teacher_profile, school: school_cohort.school }
      schedule { Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort) || create(:ecf_schedule, cohort: school_cohort.cohort) }

      after :build do |participant_profile|
        participant_profile.participant_identity = Identity::Create.call(user: participant_profile.user)
      end
    end

    factory(:ect_participant_profile, class: "ParticipantProfile::ECT") { ecf }
    factory(:mentor_participant_profile, class: "ParticipantProfile::Mentor") { ecf }

    trait :ecf_participant_validation_data do
      ecf_participant_validation_data { association :ecf_participant_validation_data }
    end

    trait :ecf_participant_eligibility do
      ecf_participant_eligibility { association :ecf_participant_eligibility }
    end

    factory :npq_participant_profile, class: "ParticipantProfile::NPQ" do
      user { create(:user) }
      schedule { Finance::Schedule::NPQLeadership.default_for(cohort:) || create(:npq_schedule, cohort:) }
      participant_identity { Identity::Create.call(user:, origin: :npq) }

      trait :eligible_for_funding do
        profile_traits { [:eligible_for_funding] }
      end

      initialize_with do
        teacher_profile = user.teacher_profile || user.build_teacher_profile

        profile = ParticipantProfile::NPQ.create!(
          schedule:,
          teacher_profile:,
          participant_identity:,
        ).tap do |pp|
          ParticipantProfileState.find_or_create_by(participant_profile: pp)
        end

        profile
      end
    end

    trait :sparsity_uplift do
      sparsity_uplift { true }
    end

    trait :pupil_premium_uplift do
      pupil_premium_uplift { true }
    end

    trait :uplift_flags do
      sparsity_uplift
      pupil_premium_uplift
    end

    trait :withdrawn_record do
      status { :withdrawn }
    end

    trait :email_sent do
      after(:create) do |profile, _evaluator|
        create :email, associated_with: profile, status: "delivered", tags: [:request_for_details]
        profile.teacher_profile.update!(trn: nil)
      end
    end

    trait :email_bounced do
      after(:create) do |profile, _evaluator|
        create :email, associated_with: profile, status: "permanent-failure", tags: [:request_for_details]
        profile.teacher_profile.update!(trn: nil)
      end
    end

    trait :primary_profile do
      profile_duplicity { :primary }
    end

    trait :secondary_profile do
      profile_duplicity { :secondary }
    end
  end
end
