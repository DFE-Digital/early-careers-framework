FactoryBot.define do
  factory :school do
    urn { "TEST URN" }
    name  { "Test school" }
    country { "England" }
    postcode { Faker::Address.postcode }
    address_line1 { Faker::Address.street_address }
  end
end
