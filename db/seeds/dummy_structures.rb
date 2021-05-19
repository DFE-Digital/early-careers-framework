# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

User.find_or_create_by!(email: "admin@example.com") do |user|
  user.update!(full_name: "Admin User")
  AdminProfile.find_or_create_by!(user: user)
end

User.find_or_create_by!(email: "lead-provider@example.com") do |user|
  user.update!(full_name: "LeadProvider User")
  LeadProviderProfile.find_or_create_by!(user: user, lead_provider: LeadProvider.first)
end

User.find_or_create_by!(email: "school-leader@example.com") do |user|
  user.update!(full_name: "InductionTutor User")
  school = School.find_or_create_by!(
    name: "Example school",
    postcode: "BB1 1BB",
    address_line1: "3 Madeup Street",
    primary_contact_email: "school-info@example.com",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
    urn: "999999",
  )
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
end

# We clear the database on a regular basis, but we want a stable token that E&L can use in its dev environments
EngageAndLearnApiToken.find_or_create_by!(hashed_token: "f4a16cd7fc10918fbc7d869d7a83df36059bb98fac7c82502d797b1f1dd73e86")
