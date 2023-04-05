# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school_local_authority, class: "SchoolLocalAuthority") do
    start_year { [2019, 2020, 2021, 2022, 2023].sample }

    trait(:with_local_authority) { association(:local_authority, factory: :seed_local_authority) }
    trait(:with_school) { association(:school, factory: :seed_school) }

    trait(:valid) do
      with_local_authority
      with_school
    end

    after(:build) do |sla|
      if sla.school.present? && sla.local_authority.present?
        Rails.logger.debug("added school #{sla.school.name} (#{sla.school.urn}) to local authority #{sla.local_authority.name} (#{sla.local_authority.code})")
      else
        Rails.logger.debug("built incomplete school_local_authority")
      end
    end
  end
end
