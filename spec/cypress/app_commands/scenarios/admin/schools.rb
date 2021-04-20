# frozen_string_literal: true

school = FactoryBot.create(:school, name: "Include this school", urn: 123_456)
FactoryBot.create(:user, :induction_coordinator, schools: [school])

Faker::UniqueGenerator.clear
Faker::Config.random = Random.new(42)
FactoryBot.create_list(:school, 20)
Faker::Config.random = nil
