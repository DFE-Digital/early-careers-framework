# frozen_string_literal: true

49.times do |n|
  # Caveat: adding new fields will change all Faker-generated data in fields
  # specified below the new ones
  Faker::UniqueGenerator.clear
  Faker::Config.random = Random.new(n)
  FactoryBot.create(:school)
end
