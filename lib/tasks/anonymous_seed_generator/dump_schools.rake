# frozen_string_literal: true

namespace(:anonymous_seed_generator) do
  desc "Dump schools to new seed files"
  task(dump_schools: :environment) do |t|
    headers = %i[
      id
      urn
      name
      school_type_code
      address_line1
      address_line2
      address_line3
      postcode
      network_id
      domains
      school_type_name
      ukprn
      school_phase_type
      school_phase_name
      school_website
      school_status_code
      school_status_name
      secondary_contact_email
      primary_contact_email
      administrative_district_code
      administrative_district_name
      slug
      section_41_approved
    ]

    rows = School
      .first(1000)
      .each
      .with_index(10_000) { |s, i|
        s.urn                          = i
        s.ukprn                        = nil
        s.address_line1                = Faker::Address.street_address
        s.address_line2                = Faker::Address.county
        s.postcode                     = Faker::Address.postcode
        s.school_website               = Faker::Internet.url
        s.primary_contact_email        = Faker::Internet.email
        s.secondary_contact_email      = Faker::Internet.email
        s.administrative_district_code = nil
        s.administrative_district_name = nil
        s.slug                         = Faker::Internet.slug
      }
      .pluck(*headers)

    print_status(t.name, rows.size) do
      dump_to_csv("schools", headers:, rows:)
    end
  end
end
