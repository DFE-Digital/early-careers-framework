# frozen_string_literal: true

school = FactoryBot.create :school, name: "Test School", slug: "test-school", urn: "123456"
cohort = FactoryBot.create :cohort, start_year: 2021
school_cohort = FactoryBot.create(:school_cohort, school: school, cohort: cohort, induction_programme_choice: "core_induction_programme")

mentor_1 = FactoryBot.create :participant_profile,
                             :mentor,
                             user: FactoryBot.create(:user, full_name: "Mentor User 1"),
                             school_cohort: school_cohort,
                             created_at: Date.parse("20/03/2020")

FactoryBot.create :participant_profile,
                  :mentor,
                  user: FactoryBot.create(:user, full_name: "Mentor User 2"),
                  school_cohort: school_cohort,
                  created_at: Date.parse("06/05/2020")

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 1", email: "young_prosacco@crist.net"),
                  mentor_profile: mentor_1,
                  school_cohort: school_cohort,
                  created_at: Date.parse("01/07/2020")

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 2"),
                  mentor_profile: mentor_1,
                  school_cohort: school_cohort,
                  created_at: Date.parse("25/05/2020")

another_school = FactoryBot.create(:school, name: "Some other school", urn: "222222")
another_school_cohort = FactoryBot.create(:school_cohort, school: another_school, cohort: cohort, induction_programme_choice: "core_induction_programme")

FactoryBot.create :participant_profile,
                  :mentor,
                  user: FactoryBot.create(:user, full_name: "Unrelated mentor"),
                  school_cohort: another_school_cohort,
                  created_at: Date.parse("10/11/2020")

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "Unrelated ect"),
                  school_cohort: another_school_cohort,
                  created_at: Date.parse("29/12/2020")

npq_profile = FactoryBot.create :participant_profile, :npq, validation_data: nil

FactoryBot.create :npq_validation_data,
                  id: npq_profile.id,
                  user: FactoryBot.create(:user, full_name: "Natalie Portman Quebec"),
                  created_at: Date.parse("19/09/2019")
