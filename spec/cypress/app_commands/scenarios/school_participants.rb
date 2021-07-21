# frozen_string_literal: true

cohort = Cohort.find_or_create_by!(start_year: 2021)
school = FactoryBot.create(:school, name: "Hogwarts Academy", slug: "111111-hogwarts-academy")
another_school = FactoryBot.create(:school, name: "Some High School", slug: "12344-some-high-school")

school_cohort = FactoryBot.create(:school_cohort, cohort: cohort, school: school, induction_programme_choice: "full_induction_programme")
another_school_cohort = FactoryBot.create(:school_cohort, cohort: cohort, school: another_school, induction_programme_choice: "full_induction_programme")

FactoryBot.create(
  :partnership,
  school: school,
  cohort: cohort,
  created_at: 2.days.ago,
  challenge_deadline: 6.days.from_now,
)

coordinator = FactoryBot.create(:user, :induction_coordinator, email: "school-leader@example.com", full_name: "Ms School Leader")
coordinator.induction_coordinator_profile.schools = [school]

mentor = FactoryBot.create(:user, :mentor, full_name: "Abdul Mentor", id: "51223b41-a562-4d94-b50c-0ce59a8bb34d", school_cohort: school_cohort)

FactoryBot.create(:user, :mentor, full_name: "Unrelated user", email: "unrelated@example.com", school_cohort: another_school_cohort)

FactoryBot.create(:user, :early_career_teacher, full_name: "Joe Bloggs", email: "joe-bloggs@example.com", school_cohort: school_cohort, mentor: mentor)
FactoryBot.create(:user, :early_career_teacher, full_name: "Dan Smith", email: "dan-smith@example.com", school_cohort: school_cohort)
