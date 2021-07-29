# frozen_string_literal: true

FactoryBot.define do
  factory :teacher_profile do
    user

    trn { Random.alphanumeric(10) }
  end
end
