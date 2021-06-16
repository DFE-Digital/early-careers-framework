# frozen_string_literal: true

school = FactoryBot.create(:school, name: "Test School", slug: "test-school")
cohort = FactoryBot.create(:cohort, start_year: 2021)

user_1 = FactoryBot.create(:user, :mentor, full_name: "Mentor User 1")
user_1.mentor_profile.update!(school: school, cohort: cohort)
user_2 = FactoryBot.create(:user, :mentor, full_name: "Mentor User 2")
user_2.mentor_profile.update!(school: school, cohort: cohort)
user_3 = FactoryBot.create(:user, :early_career_teacher, full_name: "ECT User 1", email: "young_prosacco@crist.net")
user_3.early_career_teacher_profile.update!(school: school, cohort: cohort, mentor_profile: user_1.mentor_profile)
user_4 = FactoryBot.create(:user, :early_career_teacher, full_name: "ECT User 2")
user_4.early_career_teacher_profile.update!(school: school, cohort: cohort, mentor_profile: user_1.mentor_profile)

FactoryBot.create(:user, :early_career_teacher, full_name: "Unrelated user 1")
FactoryBot.create(:user, :mentor, full_name: "Unrelated user 2")
