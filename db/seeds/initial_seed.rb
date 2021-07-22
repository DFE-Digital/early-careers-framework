# frozen_string_literal: true

cohort_2021 = Cohort.find_or_create_by!(start_year: 2021)

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
  provider.update!(cohorts: [cohort_2021]) unless provider.cohorts.any?
  LeadProviderCip.find_or_create_by!(lead_provider: provider, cohort: cohort_2021, core_induction_programme: seed[:cip])
end

PrivacyPolicy.find_or_initialize_by(major_version: 1, minor_version: 0)
  .tap { |pp| pp.html = Rails.root.join("db/seeds/privacy_policy_1.0.html").read }
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
].each do |hash|
  NPQCourse.find_or_create_by!(name: hash[:name], id: hash[:id], identifier: hash[:identifier])
end

all_provider_names = (LeadProvider.pluck(:name) + NPQLeadProvider.pluck(:name)).uniq

all_provider_names.each do |name|
  CpdLeadProvider.find_or_create_by!(name: name)
end

LeadProvider.all.each do |lp|
  lp.update!(cpd_lead_provider: CpdLeadProvider.find_by(name: lp.name))
end

NPQLeadProvider.all.each do |lp|
  lp.update!(cpd_lead_provider: CpdLeadProvider.find_by(name: lp.name))
end

if Rails.env.development?
  [
    { name: "Ambition Institute", token: "ambition-token" },
    { name: "Best Practice Network", token: "best-practice-token" },
    { name: "Capita", token: "capita-token" },
    { name: "Education Development Trust", token: "edt-token" },
    { name: "Teach First", token: "teach-first-token" },
    { name: "UCL Institute of Education", token: "ucl-token" },
  ].each do |hash|
    cpd_lead_provider = CpdLeadProvider.find_by(name: hash[:name])
    LeadProviderApiToken.create_with_known_token!(hash[:token], cpd_lead_provider: cpd_lead_provider)
  end
end
