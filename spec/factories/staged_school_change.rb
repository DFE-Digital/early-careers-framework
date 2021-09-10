# frozen_string_literal: true

FactoryBot.define do
  factory :staged_school_change, class: "DataStage::SchoolChange" do
    school { staged_school }
    attribute_changes { { school_status_code: 1, school_status_name: "Open" } }
    status { "changed" }
    handled { false }

    trait :opening do
      attribute_changes do
        {
          school_status_code: [4, 1],
          school_status_name: %w[proposed_to_open open],
        }
      end
    end

    trait :closing do
      attribute_changes do
        {
          school_status_code: [3, 2],
          school_status_name: %w[proposed_to_close closed],
        }
      end
    end

    trait :with_unhandled_changes do
      attribute_changes do
        {
          school_status_code: [4, 1],
          school_status_name: %w[proposed_to_open open],
          ukprn: %w[12345678 98765421],
        }
      end
    end

    trait :handled do
      handled { true }
    end
  end
end
