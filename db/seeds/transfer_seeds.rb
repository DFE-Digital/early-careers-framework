# frozen_string_literal: true

# NOTE: These seeds are short lived, and should be tidied up and/or deleted before this PR is merged.

# *INCOMING* school and SIT
SchoolCohort.where(induction_programme_choice: InductionProgramme.training_programmes.keys).find_each do |sc|
  programme = InductionProgramme.find_or_create_by!(school_cohort: sc, training_programme: sc.induction_programme_choice, partnership: sc.school.partnerships.active.where(cohort: sc.cohort).first, core_induction_programme: sc.core_induction_programme)
  sc.ecf_participant_profiles.each { |profile| Induction::Enrol.call(participant_profile: profile, induction_programme: programme) unless profile.current_induction_programme == programme }
  sc.update!(default_induction_programme: programme)
end

fip_school = School.find_by(urn: "000005")

User.find_or_create_by!(full_name: "Induction Tutor for School 5", email: "cpd-test+tutor-2@digital.education.gov.uk")

school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: fip_school, induction_programme_choice: "full_induction_programme")
lead_provider = LeadProvider.find_by(name: "Ambition Institute")
delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
partnership = Partnership.find_by!(cohort: Cohort.current, delivery_partner:, school: fip_school)
partnership.update!(lead_provider:)

induction_programme = InductionProgramme.find_or_create_by!(
  school_cohort:,
  partnership:,
  training_programme: "full_induction_programme",
)
school_cohort.update!(default_induction_programme: induction_programme)

old_school = School.find_by(urn: "000103")
old_school_cohort = old_school.school_cohorts.find_by(cohort: Cohort.current)

# lead_provider = LeadProvider.find_by(name: "Ambition Institute")
old_partnership = Partnership.find_by!(cohort: Cohort.current, school: old_school, lead_provider:)
old_partnership.update!(delivery_partner:)

old_school_induction_programme = InductionProgramme.find_or_create_by!(
  school_cohort: old_school_cohort,
  partnership: old_partnership,
  training_programme: "full_induction_programme",
)
old_school_cohort.update!(
  induction_programme_choice: "full_induction_programme",
  default_induction_programme: old_school_induction_programme,
)

# FIP ECT to be transfered to *INCOMING* school
fip_ect = User.find_by!(email: "fip-ect@example.com")
fip_ect_profile = fip_ect.teacher_profile.ecf_profiles.first

Induction::Enrol.call(participant_profile: fip_ect_profile, induction_programme: old_school_cohort.default_induction_programme)
fip_ect.update!(full_name: "VLAD IMPALOR")
fip_ect_profile.create_ecf_participant_validation_data(
  full_name: fip_ect.full_name,
  date_of_birth: Date.parse("01/07/1987"),
  trn: "1000864",
  nino: nil,
)

# Withdrawn FIP ECT to be transfered to *INCOMING* school
withdrawn_fip_ect = User.find_by!(email: "withdrawn-fip-ect@example.com")
withdrawn_fip_ect_profile = withdrawn_fip_ect.teacher_profile.ecf_profiles.first

Induction::Enrol.call(participant_profile: withdrawn_fip_ect_profile, induction_programme: old_school_cohort.default_induction_programme)
withdrawn_fip_ect.update!(full_name: "STEVEN RODGERS")
withdrawn_fip_ect_profile.create_ecf_participant_validation_data(
  full_name: withdrawn_fip_ect.full_name,
  date_of_birth: Date.parse("02/02/1992"),
  trn: "1000519",
  nino: nil,
)

# FIP mentor to be transfered to *INCOMING* school
fip_mentor = User.find_by!(email: "fip-mentor@example.com")
fip_mentor_profile = fip_mentor.teacher_profile.ecf_profiles.first

Induction::Enrol.call(participant_profile: fip_mentor_profile, induction_programme: old_school_cohort.default_induction_programme)
fip_mentor.update!(full_name: "TERRI BAUER")
fip_mentor_profile.create_ecf_participant_validation_data(
  full_name: fip_mentor.full_name,
  date_of_birth: Date.parse("02/04/1978"),
  trn: "1000475",
  nino: nil,
)

# FIP ECT with different DP, same LP
old_school = School.find_by(urn: "000107")
old_school_cohort = old_school.school_cohorts.find_by(cohort: Cohort.current)

diffferent_delivery_partner = DeliveryPartner.find_or_create_by!(name: "Different Delivery Partner")

lead_provider = LeadProvider.find_by(name: "Ambition Institute")
old_partnership = Partnership.find_by!(cohort: Cohort.current, school: old_school, lead_provider:)
old_partnership.update!(delivery_partner: diffferent_delivery_partner)

fip_ect_different_dp = User.find_by!(email: "fip-ect2@example.com")
fip_ect_different_dp_profile = fip_ect_different_dp.teacher_profile.ecf_profiles.first

Induction::Enrol.call(participant_profile: fip_ect_different_dp_profile, induction_programme: old_school_cohort.default_induction_programme)
fip_ect_different_dp.update!(full_name: "STEPHANIE ARNETT")
fip_ect_different_dp_profile.create_ecf_participant_validation_data(
  full_name: fip_ect_different_dp.full_name,
  date_of_birth: Date.parse("18/11/1981"),
  trn: "1000483",
  nino: nil,
)

# FIP ECT with different Lead Provider and Delivery Partner
old_school = School.find_by(urn: "000108")
old_school_cohort = old_school.school_cohorts.find_by(cohort: Cohort.current)

diffferent_delivery_partner = DeliveryPartner.find_or_create_by!(name: "Another Delivery Partner")
different_lead_provider = LeadProvider.find_by(name: "Capita")

old_partnership = Partnership.find_by!(cohort: Cohort.current, school: old_school)
old_partnership.update!(delivery_partner: diffferent_delivery_partner, lead_provider: different_lead_provider)

fip_ect_different_lp = User.find_by!(email: "fip-ect3@example.com")
fip_ect_different_lp_profile = fip_ect_different_lp.teacher_profile.ecf_profiles.first

Induction::Enrol.call(participant_profile: fip_ect_different_lp_profile, induction_programme: old_school_cohort.default_induction_programme)
fip_ect_different_lp.update!(full_name: "SETH COHEN")
fip_ect_different_lp_profile.create_ecf_participant_validation_data(
  full_name: fip_ect_different_lp.full_name,
  date_of_birth: Date.parse("02/02/1982"),
  trn: "1000503",
  nino: nil,
)
