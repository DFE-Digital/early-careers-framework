# frozen_string_literal: true

FactoryBot.define do
  factory :teacher_profile do
    user

    trn { sprintf("%07i", Random.random_number(9_999_999)) }
  end
end
