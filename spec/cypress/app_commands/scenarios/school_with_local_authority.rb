# frozen_string_literal: true

school = FactoryBot.create(:school, name: "Test school")
local_authority = FactoryBot.create(:local_authority)
SchoolLocalAuthority.create!(school: school, local_authority: local_authority, start_year: 2021)
