# frozen_string_literal: true

registration_month = 5
registration_day = 10
academic_year_start_month = 9
academic_year_start_day = 1

# Make sure Cohort 2020 exists
Cohort.find_or_create_by!(start_year: 2020,
                          registration_start_date: Date.new(2020, registration_month, registration_day),
                          academic_year_start_date: Date.new(2020, academic_year_start_month, academic_year_start_day))

# Create cohorts since 2021 until Cohort.next
next_cohort_start_year = Date.current.year + (Date.current.month < academic_year_start_month ? 0 : 1)
cohorts = (2021..next_cohort_start_year).to_a.map do |start_year|
  Cohort.find_or_create_by!(start_year:,
                            registration_start_date: Date.new(start_year, registration_month, registration_day),
                            academic_year_start_date: Date.new(start_year, academic_year_start_month, academic_year_start_day))
end

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
  provider.update!(cohorts:) unless provider.cohorts.any?
  LeadProviderCip.find_or_create_by!(lead_provider: provider, cohort: cohorts.first, core_induction_programme: seed[:cip])
end

PrivacyPolicy.find_or_initialize_by(major_version: 1, minor_version: 0)
  .tap { |pp| pp.html = Rails.root.join("data/privacy_policy.html").read }
  .save!

all_provider_names = LeadProvider.pluck(:name).uniq

all_provider_names.each do |name|
  CpdLeadProvider.find_or_create_by!(name:)
end

LeadProvider.find_each do |lp|
  lp.update!(cpd_lead_provider: CpdLeadProvider.find_by(name: lp.name))
end
