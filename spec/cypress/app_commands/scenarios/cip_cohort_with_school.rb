# frozen_string_literal: true

cohort = Cohort.find_or_create_by!(start_year: 2021)
school = FactoryBot.create(:school, name: "Outstanding school", slug: "111111-outstanding-school")
FactoryBot.create(:school_cohort, school: school, cohort: cohort, induction_programme_choice: "core_induction_programme")
FactoryBot.create(:core_induction_programme, name: "Awesome induction course")
