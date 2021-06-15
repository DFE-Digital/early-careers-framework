# frozen_string_literal: true

cohort = FactoryBot.create(:cohort, start_year: 2021)
school = FactoryBot.create(:school, name: "Outstanding school", id: "00041221-d612-46a8-a096-87ad63ff3a7d")
FactoryBot.create(:school_cohort, school: school, cohort: cohort, induction_programme_choice: "core_induction_programme")
FactoryBot.create(:core_induction_programme, name: "Awesome induction course")
