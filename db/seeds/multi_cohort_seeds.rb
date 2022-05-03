# frozen_string_literal: true

# NOTE: These seeds are short lived, and should be tidied up and/or deleted before this PR is merged.
seed_cohort = Cohort.find_by(start_year: 2021)

# ===== FIP school and SIT ==================
fip_school = School.find_or_create_by!(urn: "090001") do |school|
  school.name = "FIP City High School"
  school.address_line1 = "FIP Street"
  school.postcode = "FFP 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
fip_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                            start_year: seed_cohort.start_year)

fip_school_cohort = SchoolCohort.find_or_initialize_by(school: fip_school, cohort: seed_cohort)

lead_provider = LeadProvider.find_by(name: "Ambition Institute")
delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
Partnership.find_or_create_by!(school: fip_school,
                               cohort: seed_cohort,
                               lead_provider: lead_provider,
                               delivery_partner: delivery_partner) do |partnership|
  partnership.challenge_deadline = Date.new(2021, 12, 1)
end


Induction::SetCohortInductionProgramme.call(school_cohort: fip_school_cohort,
                                            programme_choice: "full_induction_programme")

fip_sit = CreateInductionTutor.call(school: fip_school,
                                    email: "cpd-test+tutor-91@digital.education.gov.uk",
                                    full_name: "Induction Tutor for 090001 FIP")

fip_mentor = Mentors::Create.call(full_name: "FIP Mentor 090001",
                                  email: "fipmentor-090001@example.com",
                                  school_cohort: fip_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "FIP ECT 090001",
                                 email: "fipect-090001@example.com",
                                 school_cohort: fip_school_cohort,
                                 mentor_profile_id: fip_mentor.id)

# ===== CIP school and SIT ==================

cip_school = School.find_or_create_by!(urn: "090002") do |school|
  school.name = "CIP Primary School"
  school.address_line1 = "CIP Avenue"
  school.postcode = "CP1 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
cip_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                            start_year: seed_cohort.start_year)
cip = CoreInductionProgramme.first

cip_school_cohort = SchoolCohort.find_or_initialize_by(school: cip_school,
                                                       cohort: seed_cohort,
                                                       core_induction_programme: cip)

Induction::SetCohortInductionProgramme.call(school_cohort: cip_school_cohort,
                                            programme_choice: "core_induction_programme",
                                            core_induction_programme: cip)

cip_sit = CreateInductionTutor.call(school: cip_school,
                                    email: "cpd-test+tutor-92@digital.education.gov.uk",
                                    full_name: "Induction Tutor for 090002 CIP")

cip_mentor = Mentors::Create.call(full_name: "CIP Mentor 090002",
                                  email: "cipmentor-090002@example.com",
                                  school_cohort: cip_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "CIP ECT 090002",
                                 email: "cipect-090002@example.com",
                                 school_cohort: cip_school_cohort,
                                 mentor_profile_id: cip_mentor.id)

# ===== DIY school and SIT ==================

diy_school = School.find_or_create_by!(urn: "090003") do |school|
  school.name = "DIY Grammar School"
  school.address_line1 = "DIY Towpath"
  school.postcode = "DY1 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
diy_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                            start_year: seed_cohort.start_year)

diy_school_cohort = SchoolCohort.find_or_initialize_by(school: diy_school,
                                                       cohort: seed_cohort)

Induction::SetCohortInductionProgramme.call(school_cohort: diy_school_cohort,
                                            programme_choice: "design_our_own")

diy_sit = CreateInductionTutor.call(school: diy_school,
                                    email: "cpd-test+tutor-93@digital.education.gov.uk",
                                    full_name: "Induction Tutor for 090003 DIY")

# ===== No ECTs school and SIT ==================

no_ects_school = School.find_or_create_by!(urn: "090004") do |school|
  school.name = "No ECTs Academy"
  school.address_line1 = "NO ECTs Lane"
  school.postcode = "NE1 23T"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
no_ects_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                                start_year: seed_cohort.start_year)

no_ects_school_cohort = SchoolCohort.find_or_initialize_by(school: no_ects_school,
                                                           cohort: seed_cohort)

Induction::SetCohortInductionProgramme.call(school_cohort: no_ects_school_cohort,
                                            programme_choice: "no_early_career_teachers",
                                            opt_out_of_updates: true)

no_ects_sit = CreateInductionTutor.call(school: no_ects_school,
                                    email: "cpd-test+tutor-94@digital.education.gov.uk",
                                    full_name: "Induction Tutor for 090004 NO ECTs")
