# frozen_string_literal: true

Cohort.find_or_create_by!(start_year: 2020, registration_start_date: Date.new(2020, 5, 10), academic_year_start_date: Date.new(2020, 9, 1))
cohort_2021 = Cohort.find_or_create_by!(start_year: 2021, registration_start_date: Date.new(2021, 5, 10), academic_year_start_date: Date.new(2021, 9, 1))
# moving the date back so the changes can be checked in the review app
cohort_2022 = Cohort.find_or_create_by!(start_year: 2022, registration_start_date: Date.new(2022, 4, 10), academic_year_start_date: Date.new(2022, 9, 1))

ambition_cip = CoreInductionProgramme.find_or_create_by!(name: "Ambition Institute")
edt_cip = CoreInductionProgramme.find_or_create_by!(name: "Education Development Trust")
teach_first_cip = CoreInductionProgramme.find_or_create_by!(name: "Teach First")
ucl_cip = CoreInductionProgramme.find_or_create_by!(name: "UCL Institute of Education")

[
  { provider_name: "Ambition Institute", cip: ambition_cip },
  { provider_name: "Best Practice Network", cip: ucl_cip },
  { provider_name: "Capita", cip: ambition_cip },
  { provider_name: "Education Development Trust", cip: edt_cip },
  { provider_name: "Teach First", cip: teach_first_cip },
  { provider_name: "UCL Institute of Education", cip: ucl_cip },
].each do |seed|
  provider = LeadProvider.find_or_create_by!(name: seed[:provider_name])
  provider.update!(cohorts: [cohort_2021, cohort_2022]) unless provider.cohorts.any?
  LeadProviderCip.find_or_create_by!(lead_provider: provider, cohort: cohort_2021, core_induction_programme: seed[:cip])
end

PrivacyPolicy.find_or_initialize_by(major_version: 1, minor_version: 0)
  .tap { |pp| pp.html = Rails.root.join("data/privacy_policy.html").read }
  .save!

[
  { name: "Ambition Institute", id: "9e35e998-c63b-4136-89c4-e9e18ddde0ea" },
  { name: "Best Practice Network", id: "57ba9e86-559f-4ff4-a6d2-4610c7259b67" },
  { name: "Church of England", id: "79cb41ca-cb6d-405c-b52c-b6f7c752388d" },
  { name: "Education Development Trust", id: "21e61f53-9b34-4384-a8f5-d8224dbf946d" },
  { name: "School-Led Network", id: "bc5e4e37-1d64-4149-a06b-ad10d3c55fd0" },
  { name: "Leadership Learning South East", id: "230e67c0-071a-4a48-9673-9d043d456281" },
  { name: "Teacher Development Trust", id: "30fd937e-b93c-4f81-8fff-3c27544193f1" },
  { name: "Teach First", id: "a02ae582-f939-462f-90bc-cebf20fa8473" },
  { name: "UCL Institute of Education", id: "ef687b3d-c1c0-4566-a295-16d6fa5d0fa7" },
  { name: "National Institute of Teaching", id: "3ec607f2-7a3a-421f-9f1a-9aca8a634aeb" },
].each do |hash|
  NPQLeadProvider.find_or_create_by!(name: hash[:name], id: hash[:id])
end

[
  { name: "NPQ Leading Teaching (NPQLT)", id: "15c52ed8-06b5-426e-81a2-c2664978a0dc", identifier: "npq-leading-teaching" },
  { name: "NPQ Leading Behaviour and Culture (NPQLBC)", id: "7d47a0a6-fa74-4587-92cc-cd1e4548a2e5", identifier: "npq-leading-behaviour-culture" },
  { name: "NPQ Leading Teacher Development (NPQLTD)", id: "29fee78b-30ce-4b93-ba21-80be2fde286f", identifier: "npq-leading-teaching-development" },
  { name: "NPQ for Senior Leadership (NPQSL)", id: "a42736ad-3d0b-401d-aebe-354ef4c193ec", identifier: "npq-senior-leadership" },
  { name: "NPQ for Headship (NPQH)", id: "0f7d6578-a12c-4498-92a0-2ee0f18e0768", identifier: "npq-headship" },
  { name: "NPQ for Executive Leadership (NPQEL)", id: "aef853f2-9b48-4b6a-9d2a-91b295f5ca9a", identifier: "npq-executive-leadership" },
  { name: "Additional Support Offer for new headteachers", id: "7fbefdd4-dd2d-4a4f-8995-d59e525124b7", identifier: "npq-additional-support-offer" },

  { name: "The Early Headship Coaching Offer", id: "0222d1a8-a8e1-42e3-a040-2c585f6c194a", identifier: "npq-early-headship-coaching-offer" },
  { name: "NPQ Early Years Leadership (NPQEYL)", id: "66dff4af-a518-498f-9042-36a41f9e8aa7", identifier: "npq-early-years-leadership" },
  { name: "NPQ Leading Literacy (NPQLL)", id: "829fcd45-e39d-49a9-b309-26d26debfa90", identifier: "npq-leading-literacy" },
].each do |hash|
  NPQCourse.find_or_create_by!(name: hash[:name], id: hash[:id], identifier: hash[:identifier])
end

all_provider_names = (LeadProvider.pluck(:name) + NPQLeadProvider.pluck(:name)).uniq

all_provider_names.each do |name|
  CpdLeadProvider.find_or_create_by!(name:)
end

LeadProvider.all.each do |lp|
  lp.update!(cpd_lead_provider: CpdLeadProvider.find_by(name: lp.name))
end

NPQLeadProvider.all.each do |lp|
  lp.update!(cpd_lead_provider: CpdLeadProvider.find_by(name: lp.name))
end

Importers::SeedStatements.new.call
