# frozen_string_literal: true

FactoryBot.define do
  factory :npq_application do
    transient do
      user { association :user }
    end

    npq_course
    npq_lead_provider
    participant_identity { association :identity, user: user }

    headteacher_status { NPQApplication.headteacher_statuses.keys.sample }
    funding_choice { NPQApplication.funding_choices.keys.sample }
    school_urn { rand(100_000..999_999).to_s }
    school_ukprn { rand(10_000_000..99_999_999).to_s }
    date_of_birth { rand(25..50).years.ago + rand(0..365).days }
    teacher_reference_number { rand(1_000_000..9_999_999).to_s }

    trait :accepted do
      after :create do |npq_application|
        NPQ::Accept.call(npq_application: npq_application)
      end
    end
  end
end
