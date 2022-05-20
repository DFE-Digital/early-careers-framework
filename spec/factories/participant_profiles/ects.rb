# frozen_string_literal: true

FactoryBot.define do
  factory :ect, class: "ParticipantProfile::ECT" do
    user
    school_cohort
    transient do
      mentor_profile { create :mentor }
    end

    initialize_with do
      EarlyCareerTeachers::Create.call(
        email: user.email,
        full_name: user.full_name,
        school_cohort: school_cohort,
        mentor_profile_id: mentor_profile.id,
      )
    end
  end
end
