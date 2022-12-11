# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school, class: "School") do
    transient { location { Faker::Address.city } }
    transient { domain { [location.parameterize, Faker::Internet.domain_suffix].join } }

    urn { Faker::Number.unique.decimal_part(digits: 7).to_s }
    name { [location, %w[High Grammar Infant Nursery].sample, "School"].join(" ") }
    postcode { Faker::Address.postcode }
    address_line1 { Faker::Address.street_address }
    address_line3 { location }
    domains { Array.wrap(domain) }
    school_website { "www.#{domain}" }
    primary_contact_email { Faker::Internet.email(domain:) }

    after(:build) { |s| Rails.logger.debug("seeded school #{s.name}") }
  end
end
