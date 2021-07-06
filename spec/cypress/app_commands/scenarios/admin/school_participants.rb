# frozen_string_literal: true

school = FactoryBot.create(:school, name: "Test School", slug: "test-school", urn: "123456")
cohort = Cohort.find_or_create_by!(start_year: 2021)

FactoryBot.create(:participant_profile, :mentor,
                  user: FactoryBot.create(:user, full_name: "Mentor User 1"),
                  school: school,
                  cohort: cohort)
FactoryBot.create(:participant_profile, :mentor,
                  user: FactoryBot.create(:user, full_name: "Mentor User 2"),
                  school: school,
                  cohort: cohort)
FactoryBot.create(:participant_profile, :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 1"),
                  school: school,
                  cohort: cohort)
FactoryBot.create(:participant_profile, :ect,
                  user: FactoryBot.create(:user, full_name: "ECT User 2"),
                  school: school,
                  cohort: cohort)

FactoryBot.create(:participant_profile, :mentor,
                  user: FactoryBot.create(:user, full_name: "Unrelated mentor"),
                  school: FactoryBot.create(:school, name: "Some other school"))

FactoryBot.create(:participant_profile, :ect,
                  user: FactoryBot.create(:user, full_name: "Unrelated ect"),
                  school: FactoryBot.create(:school, name: "Some other school"))
