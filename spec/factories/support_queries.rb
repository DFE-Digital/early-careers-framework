# frozen_string_literal: true

FactoryBot.define do
  factory :support_query do
    message { SecureRandom.uuid }
    user { create(:user) }
    subject { :unspecified }
    additional_information { {} }

    trait :change_lead_provider do
      subject { "change-participant-lead-provider" }
      additional_information do
        {
          participant_profile_id: create(:participant_profile).id,
          school: create(:school).id,
        }
      end
    end
  end
end
