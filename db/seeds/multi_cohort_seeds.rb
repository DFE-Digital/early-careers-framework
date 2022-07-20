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
                               lead_provider:,
                               delivery_partner:) do |partnership|
  partnership.challenge_deadline = Date.new(2021, 12, 1)
end

Induction::SetCohortInductionProgramme.call(school_cohort: fip_school_cohort,
                                            programme_choice: "full_induction_programme")

CreateInductionTutor.call(school: fip_school,
                          email: "cpd-test+tutor-91@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090001 FIP")

fip_mentor = Mentors::Create.call(full_name: "FIP Mentor 090001",
                                  email: "fipmentor-090001@example.com",
                                  school_cohort: fip_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "FIP ECT 090001",
                                 email: "fipect-090001@example.com",
                                 school_cohort: fip_school_cohort,
                                 mentor_profile_id: fip_mentor.id)

# ===== FIP school 2 and SIT ==================
fip2_school = School.find_or_create_by!(urn: "090002") do |school|
  school.name = "FIP2 City High School"
  school.address_line1 = "FIP Street"
  school.postcode = "FFP 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
fip2_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                             start_year: seed_cohort.start_year)

fip2_school_cohort = SchoolCohort.find_or_initialize_by(school: fip2_school, cohort: seed_cohort)

lead_provider = LeadProvider.find_by(name: "Ambition Institute")
delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
Partnership.find_or_create_by!(school: fip2_school,
                               cohort: seed_cohort,
                               lead_provider:,
                               delivery_partner:) do |partnership|
  partnership.challenge_deadline = Date.new(2021, 12, 1)
end

Cohort.all.each do |cohort|
  ProviderRelationship.find_or_create_by!(cohort:,
                                          lead_provider:,
                                          delivery_partner:)
end

Induction::SetCohortInductionProgramme.call(school_cohort: fip2_school_cohort,
                                            programme_choice: "full_induction_programme")

CreateInductionTutor.call(school: fip2_school,
                          email: "cpd-test+tutor-92@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090002 FIP")

fip2_mentor = Mentors::Create.call(full_name: "FIP Mentor 090002",
                                   email: "fipmentor-090002@example.com",
                                   school_cohort: fip2_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "FIP ECT 090002",
                                 email: "fipect-090002@example.com",
                                 school_cohort: fip2_school_cohort,
                                 mentor_profile_id: fip2_mentor.id)

# ===== FIP school 3 and SIT ==================
fip3_school = School.find_or_create_by!(urn: "090003") do |school|
  school.name = "FIP3 City High School"
  school.address_line1 = "FIP Street"
  school.postcode = "FFP 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
fip3_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                             start_year: seed_cohort.start_year)

fip3_school_cohort = SchoolCohort.find_or_initialize_by(school: fip3_school, cohort: seed_cohort)

lead_provider = LeadProvider.find_by(name: "Ambition Institute")
delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
Partnership.find_or_create_by!(school: fip3_school,
                               cohort: seed_cohort,
                               lead_provider:,
                               delivery_partner:) do |partnership|
  partnership.challenge_deadline = Date.new(2021, 12, 1)
end

Induction::SetCohortInductionProgramme.call(school_cohort: fip3_school_cohort,
                                            programme_choice: "full_induction_programme")

CreateInductionTutor.call(school: fip3_school,
                          email: "cpd-test+tutor-93@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090003 FIP")

fip3_mentor = Mentors::Create.call(full_name: "FIP Mentor 090003",
                                   email: "fipmentor-090003@example.com",
                                   school_cohort: fip3_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "FIP ECT 090003",
                                 email: "fipect-090003@example.com",
                                 school_cohort: fip3_school_cohort,
                                 mentor_profile_id: fip3_mentor.id)

# ===== CIP school and SIT ==================

cip_school = School.find_or_create_by!(urn: "090010") do |school|
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

CreateInductionTutor.call(school: cip_school,
                          email: "cpd-test+tutor-910@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090010 CIP")

cip_mentor = Mentors::Create.call(full_name: "CIP Mentor 090010",
                                  email: "cipmentor-090010@example.com",
                                  school_cohort: cip_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "CIP ECT 090010",
                                 email: "cipect-090010@example.com",
                                 school_cohort: cip_school_cohort,
                                 mentor_profile_id: cip_mentor.id)

# ===== CIP2 school and SIT ==================

cip2_school = School.find_or_create_by!(urn: "090011") do |school|
  school.name = "CIP2 Primary School"
  school.address_line1 = "CIP Avenue"
  school.postcode = "CP1 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
cip2_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                             start_year: seed_cohort.start_year)
cip = CoreInductionProgramme.first

cip2_school_cohort = SchoolCohort.find_or_initialize_by(school: cip2_school,
                                                        cohort: seed_cohort,
                                                        core_induction_programme: cip)

Induction::SetCohortInductionProgramme.call(school_cohort: cip2_school_cohort,
                                            programme_choice: "core_induction_programme",
                                            core_induction_programme: cip)

CreateInductionTutor.call(school: cip2_school,
                          email: "cpd-test+tutor-911@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090011 CIP2")

cip2_mentor = Mentors::Create.call(full_name: "CIP Mentor 090011",
                                   email: "cipmentor-090011@example.com",
                                   school_cohort: cip2_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "CIP ECT 090011",
                                 email: "cipect-090011@example.com",
                                 school_cohort: cip2_school_cohort,
                                 mentor_profile_id: cip2_mentor.id)

# ===== CIP3 school and SIT ==================

cip3_school = School.find_or_create_by!(urn: "090012") do |school|
  school.name = "CIP3 Primary School"
  school.address_line1 = "CIP Avenue"
  school.postcode = "CP1 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
cip3_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                             start_year: seed_cohort.start_year)
cip = CoreInductionProgramme.first

cip3_school_cohort = SchoolCohort.find_or_initialize_by(school: cip3_school,
                                                        cohort: seed_cohort,
                                                        core_induction_programme: cip)

Induction::SetCohortInductionProgramme.call(school_cohort: cip3_school_cohort,
                                            programme_choice: "core_induction_programme",
                                            core_induction_programme: cip)

CreateInductionTutor.call(school: cip3_school,
                          email: "cpd-test+tutor-912@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090012 CIP3")

cip3_mentor = Mentors::Create.call(full_name: "CIP Mentor 090012",
                                   email: "cipmentor-090012@example.com",
                                   school_cohort: cip3_school_cohort)

EarlyCareerTeachers::Create.call(full_name: "CIP ECT 090012",
                                 email: "cipect-090012@example.com",
                                 school_cohort: cip3_school_cohort,
                                 mentor_profile_id: cip3_mentor.id)

# ===== DIY school and SIT ==================

diy_school = School.find_or_create_by!(urn: "090020") do |school|
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

CreateInductionTutor.call(school: diy_school,
                          email: "cpd-test+tutor-920@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090020 DIY")

# ===== DIY2 school and SIT ==================

diy2_school = School.find_or_create_by!(urn: "090021") do |school|
  school.name = "DIY2 Grammar School"
  school.address_line1 = "DIY Towpath"
  school.postcode = "DY1 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
diy2_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                             start_year: seed_cohort.start_year)

diy2_school_cohort = SchoolCohort.find_or_initialize_by(school: diy2_school,
                                                        cohort: seed_cohort)

Induction::SetCohortInductionProgramme.call(school_cohort: diy2_school_cohort,
                                            programme_choice: "design_our_own")

CreateInductionTutor.call(school: diy2_school,
                          email: "cpd-test+tutor-921@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090021 DIY2")

# ===== DIY3 school and SIT ==================

diy3_school = School.find_or_create_by!(urn: "090022") do |school|
  school.name = "DIY3 Grammar School"
  school.address_line1 = "DIY Towpath"
  school.postcode = "DY1 23P"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
diy3_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                             start_year: seed_cohort.start_year)

diy3_school_cohort = SchoolCohort.find_or_initialize_by(school: diy3_school,
                                                        cohort: seed_cohort)

Induction::SetCohortInductionProgramme.call(school_cohort: diy3_school_cohort,
                                            programme_choice: "design_our_own")

CreateInductionTutor.call(school: diy3_school,
                          email: "cpd-test+tutor-922@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090022 DIY3")

# ===== No ECTs school and SIT ==================

no_ects_school = School.find_or_create_by!(urn: "090030") do |school|
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

CreateInductionTutor.call(school: no_ects_school,
                          email: "cpd-test+tutor-930@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090030 NO ECTs")

# ===== No ECTs school 2 and SIT ==================

no_ects2_school = School.find_or_create_by!(urn: "090031") do |school|
  school.name = "No ECTs2 Academy"
  school.address_line1 = "NO ECTs Lane"
  school.postcode = "NE1 23T"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
no_ects2_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                                 start_year: seed_cohort.start_year)

no_ects2_school_cohort = SchoolCohort.find_or_initialize_by(school: no_ects2_school,
                                                            cohort: seed_cohort)

Induction::SetCohortInductionProgramme.call(school_cohort: no_ects2_school_cohort,
                                            programme_choice: "no_early_career_teachers",
                                            opt_out_of_updates: true)

CreateInductionTutor.call(school: no_ects2_school,
                          email: "cpd-test+tutor-931@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090031 NO ECTs 2")

# ===== No ECTs school 3 and SIT ==================

no_ects3_school = School.find_or_create_by!(urn: "090032") do |school|
  school.name = "No ECTs2 Academy"
  school.address_line1 = "NO ECTs Lane"
  school.postcode = "NE1 23T"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
no_ects3_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                                 start_year: seed_cohort.start_year)

no_ects3_school_cohort = SchoolCohort.find_or_initialize_by(school: no_ects3_school,
                                                            cohort: seed_cohort)

Induction::SetCohortInductionProgramme.call(school_cohort: no_ects3_school_cohort,
                                            programme_choice: "no_early_career_teachers",
                                            opt_out_of_updates: true)

CreateInductionTutor.call(school: no_ects3_school,
                          email: "cpd-test+tutor-932@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090032 NO ECTs 2")

# ===== No choice school and SIT ==================

no_choice_school = School.find_or_create_by!(urn: "090040") do |school|
  school.name = "No Choice Infant School"
  school.address_line1 = "No Choice Street"
  school.postcode = "NE1 23T"
  school.administrative_district_code = "E901"
  school.school_status_code = 1
  school.school_type_code = 1
end
no_choice_school.school_local_authorities.create!(local_authority: LocalAuthority.first,
                                                  start_year: seed_cohort.start_year)

CreateInductionTutor.call(school: no_choice_school,
                          email: "cpd-test+tutor-940@digital.education.gov.uk",
                          full_name: "Induction Tutor for 090040 No choice")

ParticipantProfile::Mentor.joins(:induction_records).includes(induction_records: [induction_programme: [school_cohort: :school]]).merge(InductionRecord.active).find_each { |mp| Mentors::AddToSchool.call(school: mp.induction_records.active.latest.school, mentor_profile: mp) }
