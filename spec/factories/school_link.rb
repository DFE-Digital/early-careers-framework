# frozen_string_literal: true

FactoryBot.define do
  factory :school_link do
    school
    link_urn { "100000" }
    link_reason { "simple" }

    trait :successor do
      link_type { "successor" }
    end

    trait :predecessor do
      link_type { "predecessor" }
    end
  end
end
