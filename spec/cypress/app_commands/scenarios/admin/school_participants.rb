# frozen_string_literal: true

school = FactoryBot.create :school, name: "Test School", slug: "test-school", urn: "123456"
cohort = FactoryBot.create :cohort, start_year: 2021

mentor_1 = FactoryBot.create :participant_profile,
                             :mentor,
                             user: FactoryBot.create(:user, full_name: "Mentor User 1"),
                             school: school,
                             cohort: cohort,
                             created_at: Date.parse("20/03/2020")

FactoryBot.create :participant_profile,
                  :mentor,
                  user: FactoryBot.create(:user, full_name: "Mentor User 2"),
                  school: school,
                  cohort: cohort,
                  created_at: Date.parse("06/05/2020")

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 1", email: "young_prosacco@crist.net"),
                  mentor_profile: mentor_1,
                  school: school,
                  cohort: cohort,
                  created_at: Date.parse("01/07/2020")

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 2"),
                  mentor_profile: mentor_1,
                  school: school,
                  cohort: cohort,
                  created_at: Date.parse("25/05/2020")

FactoryBot.create :participant_profile,
                  :mentor,
                  user: FactoryBot.create(:user, full_name: "Unrelated mentor"),
                  school: FactoryBot.create(:school, name: "Some other school", urn: "222222"),
                  created_at: Date.parse("10/11/2020")

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "Unrelated ect"),
                  school: FactoryBot.create(:school, name: "Some other school", urn: "111111"),
                  created_at: Date.parse("29/12/2020")
