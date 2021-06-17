# frozen_string_literal: true

cohort_2021 = Cohort.find_or_create_by!(start_year: 2021)

ambition_cip = CoreInductionProgramme.find_or_create_by!(name: "Ambition Institute")
edt_cip = CoreInductionProgramme.find_or_create_by!(name: "Education Development Trust")
teach_first_cip = CoreInductionProgramme.find_or_create_by!(name: "Teach First")
ucl_cip = CoreInductionProgramme.find_or_create_by!(name: "UCL Institute of Education")

ambition = LeadProvider.find_or_create_by!(name: "Ambition Institute")
ambition.update!(cohorts: [cohort_2021]) unless ambition.cohorts.any?
LeadProviderCip.find_or_create_by!(lead_provider: ambition, cohort: cohort_2021, core_induction_programme: ambition_cip)

bpn = LeadProvider.find_or_create_by!(name: "Best Practice Network")
bpn.update!(cohorts: [cohort_2021]) unless bpn.cohorts.any?
LeadProviderCip.find_or_create_by!(lead_provider: bpn, cohort: cohort_2021, core_induction_programme: ucl_cip)

capita = LeadProvider.find_or_create_by!(name: "Capita")
capita.update!(cohorts: [cohort_2021]) unless capita.cohorts.any?
LeadProviderCip.find_or_create_by!(lead_provider: capita, cohort: cohort_2021, core_induction_programme: ambition_cip)

edt = LeadProvider.find_or_create_by!(name: "Education Development Trust")
edt.update!(cohorts: [cohort_2021]) unless edt.cohorts.any?
LeadProviderCip.find_or_create_by!(lead_provider: edt, cohort: cohort_2021, core_induction_programme: edt_cip)

teach_first = LeadProvider.find_or_create_by!(name: "Teach First")
teach_first.update!(cohorts: [cohort_2021]) unless teach_first.cohorts.any?
LeadProviderCip.find_or_create_by!(lead_provider: teach_first, cohort: cohort_2021, core_induction_programme: teach_first_cip)

ucl = LeadProvider.find_or_create_by!(name: "UCL Institute of Education")
ucl.update!(cohorts: [cohort_2021]) unless ucl.cohorts.any?
LeadProviderCip.find_or_create_by!(lead_provider: ucl, cohort: cohort_2021, core_induction_programme: ucl_cip)

PrivacyPolicy.find_or_initialize_by(major_version: 1, minor_version: 0)
  .tap { |pp| pp.html = Rails.root.join("db/seeds/privacy_policy_1.0.html").read }
  .save!

[
  "Ambition Institute",
  "Best Practice Network",
  "Church of England",
  "Education Development Trust",
  "School-Led Network",
  "Leadership Learning South East",
  "Teacher Development Trust",
  "Teach First",
  "UCL Institute of Education",
].each do |npq_lead_provider_name|
  NpqLeadProvider.find_or_create_by!(name: npq_lead_provider_name)
end

[
  "NPQ Leading Teaching (NPQLT)",
  "NPQ Leading Behaviour and Culture (NPQLBC)",
  "NPQ Leading Teacher Development (NPQLTD)",
  "NPQ for Senior Leadership (NPQSL)",
  "NPQ for Headship (NPQH)",
  "NPQ for Executive Leadership (NPQEL)",
].each do |course_name|
  NpqCourse.find_or_create_by!(name: course_name)
end
