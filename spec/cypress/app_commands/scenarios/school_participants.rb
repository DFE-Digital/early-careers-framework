# frozen_string_literal: true

cohort = Cohort.find_or_create_by!(start_year: 2021)
school = FactoryBot.create(:school, name: "Hogwarts Academy", slug: "111111-hogwarts-academy")

FactoryBot.create(:school_cohort, cohort: cohort, school: school, induction_programme_choice: "full_induction_programme")

FactoryBot.create(
  :partnership,
  school: school,
  cohort: cohort,
  created_at: 2.days.ago,
  challenge_deadline: 6.days.from_now,
)

coordinator = FactoryBot.create(:user, :induction_coordinator, email: "school-leader@example.com", full_name: "Ms School Leader")
coordinator.induction_coordinator_profile.schools = [school]

mentor = FactoryBot.create(:user, :mentor, full_name: "Abdul Mentor", id: "51223b41-a562-4d94-b50c-0ce59a8bb34d")
mentor.mentor_profile.update!(school: school)

FactoryBot.create(:user, :mentor, full_name: "Unrelated user", email: "unrelated@example.com")

ect_1 = FactoryBot.create(:user, :early_career_teacher, full_name: "Joe Bloggs")
ect_1.early_career_teacher_profile.update!(school: school, mentor_profile: mentor.mentor_profile)
ect_2 = FactoryBot.create(:user, :early_career_teacher, full_name: "Dan Smith", email: "dan-smith@example.com")
ect_2.early_career_teacher_profile.update!(school: school, mentor_profile: mentor.mentor_profile)
