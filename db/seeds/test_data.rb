# frozen_string_literal: true

DOMAIN = "@digital.education.gov.uk" # Prevent low effort email scraping
cohort_2022 = Cohort.find_or_create_by!(start_year: 2022)

local_authority = LocalAuthority.find_or_create_by!(name: "ZZ Test Local Authority", code: "ZZTEST")

School.find_or_create_by!(urn: "000001") do |school|
  school.update!(
    name: "ZZ Test School 1",
    postcode: "AA1 1AA",
    address_line1: "1 Nowhere lane",
    primary_contact_email: "cpd-pentest-1#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
end

School.find_or_create_by!(urn: "000002") do |school|
  school.update!(
    name: "ZZ Test School 2",
    postcode: "AA2 2AA",
    address_line1: "2 Nowhere lane",
    primary_contact_email: "",
    secondary_contact_email: "cpd-pentest-1#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
end

School.find_or_create_by!(urn: "000003") do |school|
  school.update!(
    name: "ZZ Test School 3",
    postcode: "AA3 3AA",
    address_line1: "3 Nowhere lane",
    primary_contact_email: "cpd-pentest-2#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  NominationEmail.find_or_create_by!(
    token: "abc123",
    sent_to: "cpd-pentest-2#{DOMAIN}",
    sent_at: 1.year.ago,
    school: school,
  )
end

School.find_or_create_by!(urn: "000004") do |school|
  school.update!(
    name: "ZZ Test School 4",
    postcode: "AA4 4AA",
    address_line1: "4 Nowhere lane",
    primary_contact_email: "cpd-pentest-1#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 4", email: "cpd-pentest-3#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
  cip = CoreInductionProgramme.first
  SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "core_induction_programme", core_induction_programme: cip)
end

School.find_or_create_by!(urn: "000005") do |school|
  school.update!(
    name: "ZZ Test School 5",
    postcode: "AA4 4AA",
    address_line1: "4 Nowhere lane",
    primary_contact_email: "cpd-test+school-5#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 5", email: "cpd-pentest-4#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
  SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "full_induction_programme")
  delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
  partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner: delivery_partner, school: school, lead_provider: LeadProvider.find_by(name: "Ambition"), challenge_deadline: 2.weeks.from_now)
  PartnershipNotificationEmail.find_or_create_by!(
    partnership: partnership,
    sent_to: "cpd-pentest-4#{DOMAIN}",
    email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
    token: "abc123",
  )
end

30.times do |idx|
  urn = (100 + idx).to_s.rjust(6, "0")
  item_num = 7 + idx
  School.find_or_create_by!(urn: urn) do |school|
    school.update!(
      name: "ZZ Test School #{item_num}",
      postcode: "AX4 9AB",
      address_line1: "#{item_num} School Lane",
      primary_contact_email: "cpd-test+school-#{item_num}#{DOMAIN}",
      school_status_code: 1,
      school_type_code: 1,
      administrative_district_code: "E#{900 + idx}",
    )
    SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
    user = User.find_or_create_by!(full_name: "Induction Tutor for School #{item_num}", email: "cpd-test+tutor-#{item_num}#{DOMAIN}")
    InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
      profile.schools << school
    end

    SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "full_induction_programme")
    delivery_partner = DeliveryPartner.find_or_create_by!(name: "Mega Delivery Partner")
    partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner: delivery_partner, school: school, lead_provider: LeadProvider.first, challenge_deadline: 2.weeks.from_now)
    PartnershipNotificationEmail.find_or_create_by!(
      partnership: partnership,
      sent_to: "cpd-test+tutor-3#{DOMAIN}",
      email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
      token: "abc424#{item_num}",
    )

    if idx.even?
      cip = CoreInductionProgramme.all.sample
      SchoolCohort.find_or_create_by!(cohort: cohort_2022, school: school, induction_programme_choice: "core_induction_programme", core_induction_programme: cip)
    end
  end
end

School.find_or_create_by!(urn: "000006") do |school|
  school.update!(
    name: "ZZ Test School 6",
    postcode: "AX4 9AB",
    address_line1: "27 School Lane",
    primary_contact_email: "cpd-test+school-6#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E901",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 6", email: "cpd-test+tutor-3#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
  SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "full_induction_programme")
  delivery_partner = DeliveryPartner.find_or_create_by!(name: "Mega Delivery Partner")
  partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner: delivery_partner, school: school, lead_provider: LeadProvider.first)
  PartnershipNotificationEmail.find_or_create_by!(
    partnership: partnership,
    sent_to: "cpd-test+tutor-3#{DOMAIN}",
    email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
    token: "abc424",
  )
  PupilPremium.find_or_create_by!(school: school, start_year: 2021, total_pupils: 500, eligible_pupils: 300)
end

delivery_partner = DeliveryPartner.find_or_create_by!(name: "Amazing Delivery Partner")

ProviderRelationship.find_or_create_by!(
  lead_provider: LeadProvider.first,
  delivery_partner: delivery_partner,
  cohort: Cohort.current,
)

example_contract_data = {
  "uplift_target": 0.33,
  "uplift_amount": 100,
  "recruitment_target": 2000,
  "set_up_fee": 149_861,
  "band_a": {
    "max": 2000,
    "per_participant": 995,
  },
  "band_b": {
    "min": 2001,
    "max": 4000,
    "per_participant": 979,
  },
  "band_c": {
    "min": 4001,
    "per_participant": 966,
  },
}

LeadProvider.all.each do |lp|
  sample_call_off_contract = CallOffContract.find_or_create_by!(
    lead_provider: lp,
    version: example_contract_data[:version] || "0.0.1",
    uplift_target: example_contract_data[:uplift_target],
    uplift_amount: example_contract_data[:uplift_amount],
    recruitment_target: example_contract_data[:recruitment_target],
    set_up_fee: example_contract_data[:set_up_fee],
    raw: example_contract_data.to_json,
  )

  %i[band_a band_b band_c].each do |band|
    src = example_contract_data[band]
    ParticipantBand.find_or_create_by!(
      call_off_contract: sample_call_off_contract,
      min: src[:min],
      max: src[:max],
      per_participant: src[:per_participant],
    )
  end
end

User.find_or_create_by!(email: "cpd-pentest-5#{DOMAIN}") do |user|
  user.update!(full_name: "Admin User1")
  AdminProfile.find_or_create_by!(user: user)
end

User.find_or_create_by!(email: "cpd-pentest-6#{DOMAIN}") do |user|
  user.update!(full_name: "Admin User2")
  AdminProfile.find_or_create_by!(user: user)
end

ambition = LeadProvider.find_by(name: "Ambition Institute")
bpn = LeadProvider.find_by(name: "Best Practice Network")

User.find_or_create_by!(email: "cpd-pentest-7#{DOMAIN}") do |user|
  user.update!(full_name: "Lead ProviderUser1")
  LeadProviderProfile.find_or_create_by!(user: user, lead_provider: ambition)
  LeadProviderApiToken.create!(lead_provider: ambition, hashed_token: "bfb452de196962338cd45dffc96060df2da6b397c3d9c9a0e4b4ec927695f12d")
end

User.find_or_create_by!(email: "cpd-pentest-8#{DOMAIN}") do |user|
  user.update!(full_name: "Lead ProviderUser2")
  LeadProviderProfile.find_or_create_by!(user: user, lead_provider: bpn)
  LeadProviderApiToken.create!(lead_provider: bpn, hashed_token: "f47af3fcff81205f908854fc8db2bd2c175ccb781936f24a153471a871a7a620")
end

FeatureFlag.activate(:participant_data_api)
FeatureFlag.activate(:induction_tutor_manage_participants)
