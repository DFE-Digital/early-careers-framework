# frozen_string_literal: true

FactoryBot.define do
  factory :cohort do
    start_year { Faker::Number.unique.between(from: 2021, to: 2100) }

    trait :current do
      # In order for factory_bot to correctly use seeds in the database you have to jump through a couple of hoops,
      # Detailed in: https://dev.to/jooeycheng/factorybot-findorcreateby-3h8k
      to_create do |instance|
        instance.attributes = Cohort.find_or_create_by!(start_year: 2021).attributes
        instance.instance_variable_set("@new_record", false)
      end
    end
  end
end
