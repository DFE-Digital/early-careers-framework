# frozen_string_literal: true

ambition_cip = FactoryBot.create(:seed_core_induction_programme, name: "Ambition Institute")
edt_cip = FactoryBot.create(:seed_core_induction_programme, name: "Education Development Trust")
teach_first_cip = FactoryBot.create(:seed_core_induction_programme, name: "Teach First")
ucl_cip = FactoryBot.create(:seed_core_induction_programme, name: "UCL Institute of Education")

cohort_2021 = Cohort.find_by(start_year: 2021)
cohort_2022 = Cohort.find_by(start_year: 2022)

{
  ambition_cip => [
    ambition_cip.name,
    "Capita",
  ],
  ucl_cip => [
    ucl_cip.name,
    "Best Practice Network",
  ],
  edt_cip => [
    edt_cip.name,
  ],
  teach_first_cip => [
    teach_first_cip.name,
  ],
}.each do |cip, names|
  names.each do |name|
    FactoryBot.create(:seed_lead_provider, name:).tap do |lead_provider|
      lead_provider.update!(cohorts: [cohort_2021, cohort_2022])

      # FIXME: what about 2022? omitted in legacy
      FactoryBot.create(:seed_lead_provider_cip, lead_provider:, cohort: cohort_2021, core_induction_programme: cip)
    end
  end
end
