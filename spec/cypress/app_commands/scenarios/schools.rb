# frozen_string_literal: true

49.times do |n|
  # Caveat: adding new fields will change all Faker-generated data in fields
  # specified below the new ones
  Faker::UniqueGenerator.clear
  Faker::Config.random = Random.new(n)

  traits = []

  if Faker::Boolean.boolean(true_ratio: 0.2)
    traits.push(:pupil_premium_uplift)
  end

  if Faker::Boolean.boolean(true_ratio: 0.2)
    # traits.push(:sparsity_uplift)
  end

  FactoryBot.create(:school, *traits)
end
