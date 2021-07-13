# frozen_string_literal: true

school = FactoryBot.create :school, name: "Test School", slug: "test-school", urn: "123456"
cohort = FactoryBot.create :cohort, start_year: 2021

mentor_1 = FactoryBot.create :participant_profile,
                             :mentor,
                             user: FactoryBot.create(:user, full_name: "Mentor User 1"),
                             school: school,
                             cohort: cohort

FactoryBot.create :participant_profile,
                  :mentor,
                  user: FactoryBot.create(:user, full_name: "Mentor User 2"),
                  school: school,
                  cohort: cohort

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 1", email: "young_prosacco@crist.net"),
                  mentor_profile: mentor_1,
                  school: school,
                  cohort: cohort

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 2"),
                  mentor_profile: mentor_1,
                  school: school,
                  cohort: cohort

FactoryBot.create :participant_profile,
                  :mentor,
                  user: FactoryBot.create(:user, full_name: "Unrelated mentor"),
                  school: FactoryBot.create(:school, name: "Some other school", urn: "222222")

FactoryBot.create :participant_profile,
                  :ect,
                  user: FactoryBot.create(:user, full_name: "Unrelated ect"),
                  school: FactoryBot.create(:school, name: "Some other school", urn: "111111")
