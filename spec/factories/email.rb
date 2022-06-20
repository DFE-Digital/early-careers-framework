# frozen_string_literal: true

FactoryBot.define do
  factory :email do
    transient do
      associated_with { [] }
    end

    after(:create) do |email, evaluator|
      Array.wrap(evaluator.associated_with).each do |object, as: nil|
        email.create_association_with(object, as:)
      end
    end
  end
end
