# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school, class: "School") do
    transient { location { Faker::Address.city } }
    transient { domain { [location.parameterize, Faker::Internet.domain_suffix].join(".") } }

    urn { Faker::Number.unique.decimal_part(digits: 7).to_s }
    name { [location, %w[High Grammar Infant Nursery].sample, "School"].join(" ") }
    postcode { Faker::Address.postcode }
    address_line1 { Faker::Address.street_address }
    address_line3 { location }
    domains { Array.wrap(domain) }
    school_website { "www.#{domain}" }
    primary_contact_email { Faker::Internet.email(domain:) }

    school_status_code { 1 }
    school_type_code { 1 }
    administrative_district_code { "E123" }

    trait(:closed) { school_status_code { 2 } }

    trait(:with_induction_coordinator) do
      induction_coordinator_profiles { FactoryBot.build_list(:seed_induction_coordinator_profile, 2, :with_user) }
    end

    trait(:cip_only) { school_type_code { GiasTypes::CIP_ONLY_TYPE_CODES.sample } }
    trait(:ineligible) { school_type_code { 10 } }

    trait(:with_pupil_premium_uplift) do
      transient do
        start_year { build(:cohort, :current).start_year }
      end

      pupil_premiums { [build(:seed_pupil_premium, :with_pupil_premiums, start_year:)] }
    end

    trait(:with_sparsity_uplift) do
      transient do
        start_year { build(:cohort, :current).start_year }
      end

      pupil_premiums { [build(:seed_pupil_premium, :with_sparsity, start_year:)] }
    end

    trait(:with_uplifts) do
      transient do
        start_year { build(:cohort, :current).start_year }
      end

      pupil_premiums { [build(:seed_pupil_premium, :with_uplifts, start_year:)] }
    end

    trait(:valid) {}

    after(:build) { |s| Rails.logger.debug("seeded school #{s.name}") }
  end
end
