# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

Schools.where(urn: %w[0082379 0082380 0082380 0082380]).destroy_all
NominationEmail.where(token: %w[normal_nomination_email
                                expired_nomination_email
                                already_nominated_induction_tutor_email
                                email_address_already_used_for_another_school]).destroy_all

school_one_hash = { "urn" => "0082379", "name" => "Email Nomination School", "school_type_code" => 1, "address_line1" => "2033 Dickinson Squares", "postcode" => "92635", "domains" => ["hoeger-shanahan.com"], "primary_contact_email" => "mehmet.duran@digital.education.gov.uk", "administrative_district_code" => "E123" }
school_two_hash = { "urn" => "0082380", "name" => "Second Email Nomination School", "school_type_code" => 1, "address_line1" => "2050 Dickinson Squares", "postcode" => "92636", "domains" => ["bazinga-foo.com"], "primary_contact_email" => "mehmet.duran@digital.education.gov.uk", "administrative_district_code" => "E123" }
school_three_hash = { "urn" => "0082380", "name" => "Third Email Nomination School", "school_type_code" => 1, "address_line1" => "2046 Dickinson Squares", "postcode" => "92640", "domains" => ["bazinga-bar.com"], "primary_contact_email" => "mehmet.duran@digital.education.gov.uk", "administrative_district_code" => "E123" }
school_four_hash = { "urn" => "0082380", "name" => "Fourth Email Nomination School", "school_type_code" => 1, "address_line1" => "2050 Dickinson Squares", "postcode" => "92646", "domains" => ["bazinga-baz.com"], "primary_contact_email" => "mehmet.duran@digital.education.gov.uk", "administrative_district_code" => "E123" }
nomination_email_school_one = School.create!(school_one_hash)
nomination_email_school_two = School.create!(school_two_hash)
nomination_email_school_three = School.create!(school_three_hash)
nomination_email_school_four = School.create!(school_four_hash)

normal_nomination_email = NominationEmail.create!(token: "normal_nomination_email",
                                                  sent_to: "mehmet.duran@digital.education.gov.uk",
                                                  sent_at: Time.zone.now,
                                                  school: nomination_email_school_one)

expired_nomination_email = NominationEmail.create!(token: "expired_nomination_email",
                                                   sent_to: "mehmet.duran+expired@digital.education.gov.uk",
                                                   sent_at: 1.year.ago,
                                                   school: nomination_email_school_one)

already_nominated_induction_tutor_email = NominationEmail.create!(token: "already_nominated_induction_tutor_email",
                                                                  sent_to: "mehmet.duran+already_nominated_induction_tutor_email@digital.education.gov.uk",
                                                                  sent_at: Time.zone.now,
                                                                  school: nomination_email_school_two)

email_address_already_used_for_another_school = NominationEmail.create!(token: "email_address_already_used_for_another_school",
                                                                        sent_to: "mehmet.duran+email_address_already_used_for_another_school@digital.education.gov.uk",
                                                                        sent_at: Time.zone.now,
                                                                        school: nomination_email_school_three)
# This is to make rubocop happy
normal_nomination_email.to_s
expired_nomination_email.to_s
already_nominated_induction_tutor_email.to_s
email_address_already_used_for_another_school.to_s

already_nominated_induction_tutor_email_user = User.with_discarded.find_or_create_by!(email: "mehmet.duran+already_nominated_induction_tutor_email@digital.education.gov.uk") do |u|
  u.full_name = "already_nominated_induction_tutor_email_user"
  u.confirmed_at = Time.zone.now.utc
end

email_address_already_used_for_another_school_user = User.with_discarded.find_or_create_by!(email: "mehmet.duran+already_nominated_induction_tutor_email@digital.education.gov.uk") do |u|
  u.full_name = "email_address_already_used_for_another_school_user"
  u.confirmed_at = Time.zone.now.utc
end

already_nominated_induction_tutor_email_profile = InductionCoordinatorProfile.find_or_create_by!(user: already_nominated_induction_tutor_email_user).undiscard
email_address_already_used_for_another_school_profile = InductionCoordinatorProfile.find_or_create_by!(user: email_address_already_used_for_another_school_user).undiscard
already_nominated_induction_tutor_email_profile.schools << nomination_email_school_two
email_address_already_used_for_another_school_profile.schools << nomination_email_school_four

standard_user_emails = ["admin@example.com", "lead-provider@example.com", "second-school-leader@example.com", "school-leader@example.com"]
(1..5).each do |number|
  standard_user_emails << "second-admin-#{number}@example.com"
  standard_user_emails << "second-lead-provider-#{number}@example.com"
  standard_user_emails << "second-school-leader-#{number}@example.com"
end

User.with_discarded.where(email: standard_user_emails).each do |user|
  user.undiscard
  user.admin_profile&.undiscard
  user.lead_provider_profile&.undiscard
  user.induction_coordinator_profile&.undiscard
end

(1..5).each do |number|
  user = User.with_discarded.find_or_create_by!(email: "second-admin-#{number}@example.com") do |u|
    u.full_name = "John Doe - #{number}"
    u.confirmed_at = Time.zone.now.utc
  end

  user.undiscard

  AdminProfile.with_discarded.find_or_create_by!(user: user).undiscard

  user = User.with_discarded.find_or_create_by!(email: "second-lead-provider-#{number}@example.com") do |u|
    u.full_name = "Merry Doe - #{number}"
    u.confirmed_at = Time.zone.now.utc
  end

  user.undiscard

  LeadProviderProfile.with_discarded.find_or_create_by!(user: user, lead_provider: LeadProvider.first).undiscard
end

user = User.with_discarded.find_or_create_by!(email: "admin@example.com") do |u|
  u.full_name = "Admin User"
  u.confirmed_at = Time.zone.now.utc
end

user.undiscard

AdminProfile.with_discarded.find_or_create_by!(user: user).undiscard

user = User.find_or_create_by!(email: "lead-provider@example.com") do |u|
  u.full_name = "Lp User"
  u.confirmed_at = Time.zone.now.utc
end

user.undiscard

LeadProviderProfile.find_or_create_by!(user: user, lead_provider: LeadProvider.first).undiscard

school_urns_twenty_twenty_one = %w[136089 105448 128702 113280 138229 143094 140667 127834 146786 113199 126346 133936 132971 107126 102887 102418 129369 140980 116848 112236]

School.where(urn: school_urns_twenty_twenty_one).each do |school|
  Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_or_create_by!(start_year: 2021))
end

school_urns_twenty_twenty_two = %w[119378 134847 113870 127979 144744 121499 147505 105626 402027 100173]

School.where(urn: school_urns_twenty_twenty_two).each do |school|
  Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_or_create_by!(start_year: 2022))
end

user = User.with_discarded.find_or_create_by!(email: "second-school-leader@example.com") do |u|
  u.full_name = "School Leader User - Induction Coordinator"
  u.confirmed_at = Time.zone.now.utc
end

user.undiscard

if School.any?
  InductionCoordinatorProfile.joins(:schools).find_or_create_by!(user: user, schools: [School.first]).undiscard
end

user = User.with_discarded.find_or_create_by!(email: "school-leader@example.com") do |u|
  u.full_name = "School Leader User"
  u.confirmed_at = Time.zone.now.utc
end

user.undiscard

if School.any?
  InductionCoordinatorProfile.joins(:schools).find_or_create_by!(user: user, schools: [School.first]).undiscard
end

user = User.find_or_create_by!(email: "early-career-teacher@example.com") do |u|
  u.full_name = "ECT User"
  u.confirmed_at = Time.zone.now.utc
end
if School.any?
  EarlyCareerTeacherProfile.find_or_create_by!(user: user, school: School.first, cohort: Cohort.first, core_induction_programme: CoreInductionProgramme.first)
end
