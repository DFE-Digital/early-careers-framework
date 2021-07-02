# frozen_string_literal: true

FactoryBot.define do
  factory :cohort do
    to_create do |instance|
      if (existing = Cohort.find_by(start_year: instance.start_year))
        instance.attributes = existing.attributes
        instance.instance_variable_set("@new_record", false)
      else
        instance.save!
      end
    end

    start_year { Faker::Number.unique.between(from: 2021, to: 2100) }

    trait :current do
      start_year { 2021 }
    end
  end
end
