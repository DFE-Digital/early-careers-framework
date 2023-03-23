# frozen_string_literal: true

FactoryBot
  .create_list(:seed_school, seed_quantity(:school_invitations))
  .map { |school| NewSeeds::Scenarios::School::InviteSchool.new(school:).invite! }
