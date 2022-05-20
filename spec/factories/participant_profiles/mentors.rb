# frozen_string_literal: true

FactoryBot.define do
  factory :mentor, class: "ParticipantProfile::Mentor" do
    user
    school_cohort

    initialize_with do
      Finance::Schedule::ECF.default || create(:ecf_schedule)
      Mentors::Create.call(
        email: user.email,
        full_name: user.full_name,
        school_cohort: school_cohort,
      )
    end
  end
end
