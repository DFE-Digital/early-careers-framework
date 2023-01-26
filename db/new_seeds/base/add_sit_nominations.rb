# frozen_string_literal: true

FactoryBot
  .create_list(:seed_school, 15)
  .map { |school| NewSeeds::Scenarios::School::InviteSchool.new(school:).invite! }
