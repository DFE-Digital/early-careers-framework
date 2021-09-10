# frozen_string_literal: true

FactoryBot.define do
  factory :staged_school_link, class: "DataStage::SchoolLink" do
    school { staged_school }
    link_urn { 123_456 }
    link_type { "Predecessor" }

    trait :successor do
      link_type { "Successor" }
    end
  end
end
