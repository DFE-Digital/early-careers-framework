# NOTE: These seeds are short lived, and should be tidied up and/or deleted before this PR is merged.

# *INCOMING* school and SIT
SchoolCohort.where(induction_programme_choice: InductionProgramme.training_programmes.keys).find_each do |sc|
  programme = InductionProgramme.find_or_create_by!(school_cohort: sc, training_programme: sc.induction_programme_choice, partnership: sc.school.partnerships.active.where(cohort: sc.cohort).first, core_induction_programme: sc.core_induction_programme)
  sc.ecf_participant_profiles.each { |profile| Induction::Enrol.call(participant_profile: profile, induction_programme: programme) unless profile.current_induction_programme == programme }
  sc.update!(default_induction_programme: programme)
end

fip_school = School.find_by(urn: "000005")
user = User.find_or_create_by!(full_name: "Induction Tutor for School 5", email: "cpd-test+tutor-2@digital.education.gov.uk")

school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: fip_school, induction_programme_choice: "full_induction_programme")
delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
partnership = Partnership.find_by!(cohort: Cohort.current, delivery_partner: delivery_partner, school: fip_school)

induction_programme = InductionProgramme.afind_or_create_by!(
  school_cohort: school_cohort,
  partnership: partnership,
  training_programme: "full_induction_programme",
)
school_cohort.update!(default_induction_programme: induction_programme)

# FIP ECT to be transfered to *INCOMING* school
fip_ect = User.find_by!(email: "fip-ect@example.com")
fip_ect_profile = fip_ect.teacher_profile.ecf_profiles.first

old_school = School.find_by(urn: "000103")
old_school_cohort = old_school.school_cohorts.find_by(cohort: Cohort.current)

lead_provider = LeadProvider.find_by(name: "Ambition Institute")
old_partnership = Partnership.find_by!(cohort: Cohort.current, school: old_school, lead_provider: lead_provider)

old_school_induction_programme = InductionProgramme.find_or_create_by!(
  school_cohort: old_school_cohort,
  partnership: old_partnership,
  training_programme: "full_induction_programme",
)
old_school_cohort.update!(
  induction_programme_choice: "full_induction_programme",
  default_induction_programme: old_school_induction_programme,
)

Induction::Enrol.call(participant_profile: fip_ect_profile, induction_programme: old_school_cohort.default_induction_programme)

# This is fake
fip_ect_profile.create_ecf_participant_validation_data(
  full_name: "VLAD IMPALOR",
  date_of_birth: Date.parse("01/07/1987"),
  trn: "1000864",
  nino: nil,
)