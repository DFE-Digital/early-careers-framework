# frozen_string_literal: true

FactoryBot.define do
  factory :admin_profile do
    user

    trait(:super_user) do
      super_user { true }
    end
  end
end
