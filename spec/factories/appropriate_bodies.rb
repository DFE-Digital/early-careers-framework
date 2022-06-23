FactoryBot.define do
  factory :appropriate_body do
    factory :ab_local_authority do
      sequence :name do |n|
        "Local authority #{n}"
      end
      # name { "la" }
      body_type { "local_authority" }
    end

    factory :ab_teaching_school_hub do
      sequence :name do |n|
        "Teaching school hub #{n}"
      end
      body_type { "teaching_school_hub" }
    end
  end
end
