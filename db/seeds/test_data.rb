# frozen_string_literal: true

DOMAIN = "@digital.education.gov.uk" # Prevent low effort email scraping

local_authority = LocalAuthority.find_or_create_by!(name: "ZZ Test Local Authority", code: "ZZTEST")

School.find_or_create_by!(
  name: "ZZ Test School 1",
  postcode: "AA1 1AA",
  address_line1: "1 Nowhere lane",
  primary_contact_email: "cpd-test+school-1#{DOMAIN}",
  school_status_code: 1,
  school_type_code: 1,
  administrative_district_code: "E123",
  urn: "000001",
) do |school|
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
end

School.find_or_create_by!(
  name: "ZZ Test School 2",
  postcode: "AA2 2AA",
  address_line1: "2 Nowhere lane",
  primary_contact_email: "cpd-test+school-2#{DOMAIN}",
  school_status_code: 1,
  school_type_code: 1,
  administrative_district_code: "E123",
  urn: "000002",
) do |school|
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
end

School.find_or_create_by!(
  name: "ZZ Test School 3",
  postcode: "AA3 3AA",
  address_line1: "3 Nowhere lane",
  primary_contact_email: "cpd-test+school-3#{DOMAIN}",
  school_status_code: 1,
  school_type_code: 1,
  administrative_district_code: "E123",
  urn: "000003",
) do |school|
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  NominationEmail.find_or_create_by!(
    token: "abc123",
    sent_to: "cpd-test+school-3#{DOMAIN}",
    sent_at: 1.year.ago,
    school: school,
  )
end
