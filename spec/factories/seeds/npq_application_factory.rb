# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_npq_application, class: "NPQApplication") do
    date_of_birth { Faker::Date.between(from: 70.years.ago, to: 21.years.ago) }
    headteacher_status { NPQApplication.headteacher_statuses.keys.sample }
    funding_choice { NPQApplication.funding_choices.keys.sample }
    nino { SecureRandom.hex }
    teacher_catchment { "england" }
    works_in_school { true }
    eligible_for_funding { true }

    trait(:with_participant_identity) do
      association(:participant_identity, factory: %i[seed_participant_identity valid])
    end

    trait(:with_npq_lead_provider) do
      association(:npq_lead_provider, factory: %i[seed_npq_lead_provider valid])
    end

    trait(:with_npq_course) do
      association(:npq_course, factory: %i[seed_npq_course])
    end

    trait(:ineligible_for_funding) { false }

    trait(:company) do
      works_in_school { false }
      school_urn { nil }
      school_ukprn { nil }
      employer_name { Faker::Company.name }
      employment_role { Faker::Company.profession.capitalize }
    end

    trait(:childcare) do
      works_in_school { false }
      school_urn { nil }
      school_ukprn { nil }
      works_in_nursery { true }
      works_in_childcare { true }
      kind_of_nursery { "private_nursery" }
      private_childcare_provider_urn { "EY#{SecureRandom.rand(100_000..999_999)}" }
    end

    trait(:starting_in_2021) { cohort { Cohort.find_or_create_by!(start_year: 2021) } }
    trait(:starting_in_2022) { cohort { Cohort.find_or_create_by!(start_year: 2022) } }

    trait(:valid) do
      with_participant_identity
      with_npq_lead_provider
      with_npq_course
      starting_in_2022
    end

    after(:build) do |npqa|
      if npqa.participant_identity&.persisted?
        Rails.logger.debug("seeded an npq application for #{npqa.participant_identity.user.full_name}")
      else
        Rails.logger.debug("seeded an incomplete NPQ application")
      end
    end
  end
end
