cohort = FactoryBot.create(:cohort, :current)
first_school = FactoryBot.create(:school, name: "Test School 1", slug: "111111-test-school-1")
FactoryBot.create(:school_cohort, school: first_school, cohort: cohort)
second_school = FactoryBot.create(:school, name: "Test School 2", slug: "111112-test-school-2")
FactoryBot.create(:school_cohort, school: second_school, cohort: cohort)

FactoryBot.create(:user, :induction_coordinator, email: "school-leader@example.com", school_ids: [first_school.id, second_school.id])
