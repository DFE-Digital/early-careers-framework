FactoryBot.define do
  factory :school do
    urn { "TEST URN" }
    name  { "Test school" }
    address_line1 { "Test address" }
    country { "England" }
    postcode { "AA1 1AA" }
  end
end
