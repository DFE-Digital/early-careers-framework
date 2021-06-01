# frozen_string_literal: true

school = FactoryBot.create(:school, name: "Test School", id: "a4dc302c-ab71-4d7b-a10a-3116a778e8d5")

user_1 = FactoryBot.create(:user, :early_career_teacher, full_name: "ECT User 1")
user_1.early_career_teacher_profile.update!(school: school)
user_2 = FactoryBot.create(:user, :early_career_teacher, full_name: "ECT User 2")
user_2.early_career_teacher_profile.update!(school: school)
user_3 = FactoryBot.create(:user, :mentor, full_name: "Mentor User 1")
user_3.mentor_profile.update!(school: school)
user_4 = FactoryBot.create(:user, :mentor, full_name: "Mentor User 2")
user_4.mentor_profile.update!(school: school)

FactoryBot.create(:user, :early_career_teacher, full_name: "Unrelated user 1")
FactoryBot.create(:user, :mentor, full_name: "Unrelated user 2")
