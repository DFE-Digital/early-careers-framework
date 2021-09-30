# frozen_string_literal: true

cohort = FactoryBot.create(:cohort, :current)
first_school = FactoryBot.create(:school, name: "Test School 1", slug: "111111-test-school-1", urn: "111111")
FactoryBot.create(:school_cohort, :cip, school: first_school, cohort: cohort)
second_school = FactoryBot.create(:school, name: "Test School 2", slug: "111112-test-school-2", urn: "111112")
FactoryBot.create(:school_cohort, :cip, school: second_school, cohort: cohort)
third_school = FactoryBot.create(:school, name: "Test School 3", slug: "111113-test-school-3", urn: "111113")
FactoryBot.create(:school_cohort, :cip, school: third_school, cohort: cohort)

FactoryBot.create(:user, :induction_coordinator, email: "school-leader@example.com", school_ids: [first_school.id, second_school.id])
