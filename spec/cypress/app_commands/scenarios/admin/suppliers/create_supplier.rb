# frozen_string_literal: true

cohort = FactoryBot.create(:cohort)
FactoryBot.create(:lead_provider, cohorts: [cohort])
FactoryBot.create(:core_induction_programme)
