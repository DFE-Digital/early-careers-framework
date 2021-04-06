# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

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
  delivery_partner = DeliveryPartner.create(name: "delivery partner 2021")
  Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_or_create_by!(start_year: 2021), delivery_partner: delivery_partner)
end

school_urns_twenty_twenty_two = %w[119378 134847 113870 127979 144744 121499 147505 105626 402027 100173]

School.where(urn: school_urns_twenty_twenty_two).each do |school|
  delivery_partner = DeliveryPartner.create(name: "delivery partner 2022")
  Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_or_create_by!(start_year: 2022), delivery_partner: delivery_partner)
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
