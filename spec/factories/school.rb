# frozen_string_literal: true

FactoryBot.define do
  factory :local_authority do
    code { Faker::Number.unique.decimal_part.to_s }
    name { "Test local authority" }
  end
  factory :local_authority_district do
    code { Faker::Number.unique.decimal_part.to_s }
    name { "Test local authority district" }
  end
end

FactoryBot.define do
  factory :school do
    urn { Faker::Number.unique.decimal_part(digits: 7).to_s }
    name  { Faker::University.name }
    country { "England" }
    postcode { Faker::Address.postcode }
    address_line1 { Faker::Address.street_address }
    domains { [Faker::Internet.domain_name] }
    local_authority { FactoryBot.create(:local_authority) }
    local_authority_district { FactoryBot.create(:local_authority_district) }
  end
end
