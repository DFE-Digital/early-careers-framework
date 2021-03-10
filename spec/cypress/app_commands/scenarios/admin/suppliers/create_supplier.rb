# frozen_string_literal: true

cohort = FactoryBot.create(:cohort, start_year: 2021)
FactoryBot.create(:lead_provider, name: "Lead Provider 1", cohorts: [cohort])
FactoryBot.create(:core_induction_programme, name: "CIP 1")
