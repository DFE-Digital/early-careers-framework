# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_school, class: "School") do
    transient { location { Faker::Address.city } }
    transient { domain { [location.parameterize, Faker::Internet.domain_suffix].join } }

    name { [location, %w[High Grammar Infant Nursary].sample, "School"].join(" ") }
    postcode { Faker::Address.postcode }
    address_line1 { Faker::Address.street_address }
    address_line3 { location }
    domains { Array.wrap(domain) }
    school_website { "www.#{domain}" }
    primary_contact_email { Faker::Internet.email(domain:) }
  end
end
