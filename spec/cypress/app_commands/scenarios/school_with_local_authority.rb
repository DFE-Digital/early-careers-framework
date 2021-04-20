# frozen_string_literal: true

school = FactoryBot.create(:school, urn: "0932244", name: "Test school", address_line1: "102 Bridge Street", postcode: "SE1 1AB")
local_authority = FactoryBot.create(:local_authority)
SchoolLocalAuthority.create!(school: school, local_authority: local_authority, start_year: 2021)
