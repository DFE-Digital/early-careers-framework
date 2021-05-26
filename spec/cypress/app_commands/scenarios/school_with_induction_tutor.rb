# frozen_string_literal: true

school = FactoryBot.create(:school, urn: "987654", name: "Induction High School", address_line1: "23 Credibility St.", postcode: "AB1 2EE")

local_authority = FactoryBot.create(:local_authority)
SchoolLocalAuthority.create!(school: school, local_authority: local_authority, start_year: 2021)

FactoryBot.create(:user, :induction_coordinator, schools: [school], full_name: "Brenda Walsh", email: "brenda.walsh@school.org")
