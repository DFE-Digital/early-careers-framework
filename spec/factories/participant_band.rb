# frozen_string_literal: true

FactoryBot.define do
  factory :participant_band do
    trait :band_a do
      max { 2000 }
      per_participant { 995 }
    end
    trait :band_b do
      min { 2001 }
      max { 4000 }
      per_participant { 979 }
    end
    trait :band_c do
      min { 4001 }
      per_participant { 966 }
    end
    trait :band_c_with_additional do
      min { 4001 }
      max { 4500 }
      per_participant { 966 }
    end
    trait :additional do
      min { 4501 }
      max { 5100 }
      per_participant { 966 }
    end
  end
end
